# SPIE2026_DermIDS

## DermIDS: Dermatology imaging data structure for scalable and interoperable AI systems

SPIE Medical Imaging 2026

Paper #: 13930-29

February 19, 2026

Vancouver, BC, Canada



## DermIDS Structure

![The Dermatology Imaging Data Structure (DermIDS)](DermIDS_schema/DermIDS_schema.png)

* DermIDS defines a dataset / subject / session / modality hierarchy.
* Each image is stored as a PNG file with a JSON sidecar containing image-specific clinical and technical metadata.
* All files are named based on their hierarchical folder structure: `sub-<subject_number>_ses-<session_number>_mod-<modality>_img-<image_number>`
* Supported modalities include clinical photography, dermoscopy, general photography, reflectance confocal microscopy, and surface 3D imaging.

  
## DermIDS Validator

To support compliance with the DermIDS format, the DermIDS Validator verifies directory structures, file types, and naming conventions for each dataset. This includes checking dataset, subject, session, and modality folder names and confirming that all PNG, JSON, and ICC files follow the standardized sub-<subject_number>_ses-<session_number>_mod-<modality>_img-<image_number> naming convention. Unknown file types or misnamed folders and files are flagged as errors.

Usage:
* Download the example dataset in DermIDS format (dataset_000) to a new project directory folder (/path/to/project_directory/dataset_000) and DermIDS Validator (/path/to/DermIDS_Validator.sh)

* In terminal, run the DermIDS Validator across the project directory folder:

bash DermIDS_Validator.sh /path/to/project_directory

* Verify that the DermIDS Validator produces the following outputs:

dataset: dataset_000, sub_folders: 60, modalities: "ds", pngs: 60, jsons: 60, icc: 0, total files: 120

DermIDS structure validation complete for /path/to/project_directory
