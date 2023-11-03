export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)
export LOCATION=europe-west1
export NAME=docai-service
export GCP_DOCAI_REGION=YOUR_DOCAI_PROCESSOR_REGION
export GCP_DOCAI_PROCESSOR_ID=YOUR_DOCAI_PROCESSOR_ID

gcloud services enable appengine.googleapis.com
gcloud services enable firestore.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable documentai.googleapis.com
gcloud services enable drive.googleapis.com

gcloud builds submit --tag "eu.gcr.io/$GOOGLE_CLOUD_PROJECT/$NAME"

gcloud run deploy $NAME --image eu.gcr.io/$GOOGLE_CLOUD_PROJECT/$NAME \
    --platform managed --project $GOOGLE_CLOUD_PROJECT \
    --min-instances=1 \
    --region $LOCATION --allow-unauthenticated \
    --set-env-vars GCLOUD_PROJECT="$GOOGLE_CLOUD_PROJECT",GCP_DOCAI_REGION="$GCP_DOCAI_REGION",GCP_DOCAI_PROCESSOR_ID="$GCP_DOCAI_PROCESSOR_ID"
