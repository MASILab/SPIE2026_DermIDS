#!/bin/bash
set -u

# DermIDS Validator
# Author: Chloe Cho
# chloe.cho@vanderbilt.edu

BASE_DIR="${1:-}"

if [[ -z "$BASE_DIR" ]]; then
  echo "Usage: $0 <BASE_DIR>" >&2
  exit 1
fi

if [[ ! -d "$BASE_DIR" ]]; then
  echo "ERROR: BASE_DIR '$BASE_DIR' does not exist or is not a directory" >&2
  exit 1
fi

shopt -s nullglob

declare -a ALLOWED_MODALITIES=(cp ds gp rcm s3d)

is_allowed_modality() {
  local m="$1"
  for am in "${ALLOWED_MODALITIES[@]}"; do
    [[ "$m" == "$am" ]] && return 0
  done
  return 1
}

check_structure() {
  local dataset_name="$1"
  local dataset_path="$BASE_DIR/$dataset_name"

  local sub_folders=0
  local num_png=0
  local num_json=0
  local num_icc=0
  local total_files=0
  declare -A modalities_seen

  local found_subject=0
  for sub_path in "$dataset_path"/*; do
    [[ -d "$sub_path" ]] || continue
    local sub_name
    sub_name="$(basename "$sub_path")"

    if [[ ! "$sub_name" =~ ^sub-[0-9]{7}$ ]]; then
      echo "ERROR: Unexpected folder '$sub_path' found in '$dataset_path' (expected sub-#######)"
      continue
    fi

    found_subject=1
    ((sub_folders++))

    local found_session=0
    for ses_path in "$sub_path"/*; do
      [[ -d "$ses_path" ]] || continue
      local ses_name
      ses_name="$(basename "$ses_path")"

      if [[ ! "$ses_name" =~ ^ses-[0-9]{7}$ ]]; then
        echo "ERROR: Unexpected folder '$ses_path' found in '$sub_path' (expected ses-#######)"
        continue
      fi
      found_session=1

      local found_modality=0
      for mod_path in "$ses_path"/*; do
        [[ -d "$mod_path" ]] || continue
        local mod_name
        mod_name="$(basename "$mod_path")"

        if ! is_allowed_modality "$mod_name"; then
          echo "ERROR: Unexpected modality folder '$mod_path' (expected cp|ds|gp|rcm|s3d)"
          continue
        fi

        found_modality=1
        modalities_seen["$mod_name"]=1

        local found_any_file=0
        for file in "$mod_path"/*; do
          [[ -f "$file" ]] || continue
          found_any_file=1
          ((total_files++))

          local base
          base="$(basename "$file")"

          case "$base" in
            *.png)
              ((num_png++))
              if [[ ! "$base" =~ ^sub-[0-9]{7}_ses-[0-9]{7}_mod-(cp|ds|gp|rcm|s3d)_img-[0-9]{7}\.png$ ]]; then
                echo "ERROR: PNG file '$file' does not follow expected DermIDS naming convention"
              fi
              ;;
            *.json)
              ((num_json++))
              if [[ ! "$base" =~ ^sub-[0-9]{7}_ses-[0-9]{7}_mod-(cp|ds|gp|rcm|s3d)_img-[0-9]{7}\.json$ ]]; then
                echo "ERROR: JSON file '$file' does not follow expected DermIDS naming convention"
              fi
              ;;
            *.icc)
              ((num_icc++))
              if [[ ! "$base" =~ ^sub-[0-9]{7}_ses-[0-9]{7}_mod-(cp|ds|gp|rcm|s3d)_img-[0-9]{7}\.icc$ ]]; then
                echo "ERROR: ICC file '$file' does not follow expected DermIDS naming convention"
              fi
              ;;
            *)
              echo "ERROR: Unknown file type '$file' found in '$mod_path' (expected .png .json .icc)"
              ;;
          esac
        done

        if [[ $found_any_file -eq 0 ]]; then
          echo "ERROR: No files found in modality folder '$mod_path'"
        fi
      done

      if [[ $found_modality -eq 0 ]]; then
        echo "ERROR: No modality folders found in '$ses_path' (expected cp|ds|gp|rcm|s3d)"
      fi
    done

    if [[ $found_session -eq 0 ]]; then
      echo "ERROR: No session folders found in '$sub_path' (expected ses-#######)"
    fi
  done

  if [[ $found_subject -eq 0 ]]; then
    echo "ERROR: No subject folders found in '$dataset_path' (expected sub-#######)"
  fi

  local modalities_list
  modalities_list="$(echo "${!modalities_seen[@]}" | tr ' ' ',' )"

  echo "dataset: $dataset_name, sub_folders: $sub_folders, modalities: \"${modalities_list}\", pngs: $num_png, jsons: $num_json, icc: $num_icc, total files: $total_files"
}

found_dataset=0
for dataset_path in "$BASE_DIR"/*; do
  [[ -d "$dataset_path" ]] || continue
  found_dataset=1

  dataset_name="$(basename "$dataset_path")"
  if [[ ! "$dataset_name" =~ ^dataset_[0-9]{3}$ ]]; then
    echo "ERROR: Dataset folder '$dataset_path' does not follow expected DermIDS structure (expected dataset_###)"
    continue
  fi

  check_structure "$dataset_name"
done

if [[ $found_dataset -eq 0 ]]; then
  echo "ERROR: No dataset directories found in '$BASE_DIR'"
  exit 1
fi

echo "DermIDS structure validation complete for $BASE_DIR"
