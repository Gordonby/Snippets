ADOORG="gdoggmsft"
ADOPROJ="TEST-EntScaleRepoBootstrap4"

PAT=""
B64_PAT=$(echo ":$PAT" | base64)

PROJID=""
REPOID=""
PR="41"

ARTIFACTID="vstfs:///CodeReview/CodeReviewId/$PROJID/$PR"
echo $ARTIFACTID

URL="https://dev.azure.com/$ADOORG/$ADOPROJ/_apis/policy/evaluations?artifactId=$ARTIFACTID&api-version=6.1-preview.1"

Invoke-RestMethod -Uri $url -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -Method Get