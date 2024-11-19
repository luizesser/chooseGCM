## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

Nov 16th, 2024. I have addressed Uwe Ligges comments on spell check in Rd and DESCRIPTION files.
Uwe also suggested me to include a reference on the method, if available. However, there is no article 
published yet on the method. The manuscript describing it was already submitted and is currently under 
consideration for a  journal in the area.

Nov 19th, 2024. Following suggestions from Konstanze Lauseker, I have tried to replaced dontrun with donttest 
in the worldclim_data function, but I could not pass the check process with that. In this sense, I kept
the dontrun and included the tempdir() as a path. This seems necessary, once the function will start the download of data
and will take a long time. Also, the function now does not write automatically on the user's filespace. The
user now must provide a path to save the downloaded files. I included low-resolution raw data on inst/extdata 
folder to make examples work. This lead me to unwrap them form dontrun as before.
