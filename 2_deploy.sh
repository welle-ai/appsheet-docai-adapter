gcloud services enable appengine.googleapis.com
gcloud services enable firestore.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable documentai.googleapis.com
gcloud services enable drive.googleapis.com

# Create artifact registry, if needed
gcloud artifacts repositories create docker-registry --repository-format=docker \
--location="$REGION" --description="Docker registry"    

# Create firebase db, if needed
if [[ $(gcloud app describe 2>&1 || true) == *'ERROR'* ]]; then echo 'No app engine or firestore instances found, creating...' && gcloud app create --region=europe-west; fi
gcloud alpha firestore databases update --type=firestore-native
PROJECTNUMBER=$(gcloud projects list --filter=\"$(gcloud config get-value project)\" --format=\"value(PROJECT_NUMBER)\") && gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=\"serviceAccount:$PROJECTNUMBER-compute@developer.gserviceaccount.com\" --role='roles/datastore.user'
PROJECTNUMBER=$(gcloud projects list --filter=\"$(gcloud config get-value project)\" --format=\"value(PROJECT_NUMBER)\") && gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=\"serviceAccount:$PROJECTNUMBER-compute@developer.gserviceaccount.com\" --role='roles/aiplatform.user'
PROJECTNUMBER=$(gcloud projects list --filter=\"$(gcloud config get-value project)\" --format=\"value(PROJECT_NUMBER)\") && gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=\"serviceAccount:$PROJECTNUMBER-compute@developer.gserviceaccount.com\" --role='roles/documentai.apiUser'
PROJECTNUMBER=$(gcloud projects list --filter=\"$(gcloud config get-value project)\" --format=\"value(PROJECT_NUMBER)\") && echo \"Add user $PROJECTNUMBER-compute@developer.gserviceaccount.com to your AppSheet Google Drive folder with Read permissions.\"

# Submit build
gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_LOCATION="$REGION",_REPOSITORY="docker-registry",_IMAGE="$NAME" .

gcloud run deploy $NAME --image "$REGION-docker.pkg.dev/$PROJECT/docker-registry/$NAME" \
    --platform managed --project $PROJECT \
    --min-instances=1 \
    --region $REGION --allow-unauthenticated \
    --set-env-vars GCLOUD_PROJECT="$PROJECT",GCP_DOCAI_REGION="$GCP_DOCAI_REGION",GCP_DOCAI_PROCESSOR_ID="$GCP_DOCAI_PROCESSOR_ID"
