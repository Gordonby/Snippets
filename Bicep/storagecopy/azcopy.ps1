$env:AZCOPY_CRED_TYPE = "Anonymous";
$env:AZCOPY_CONCURRENCY_VALUE = "AUTO";
$sas="";
./azcopy.exe copy "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\" "https://innerloopac06.file.core.windows.net/gordpwshazclia322/data/?$sas" --overwrite=prompt --from-to=LocalFile --follow-symlinks --check-length=true --put-md5 --follow-symlinks --preserve-smb-info=true --disable-auto-decoding=false --recursive --log-level=INFO;
$env:AZCOPY_CRED_TYPE = "";
$env:AZCOPY_CONCURRENCY_VALUE = "";