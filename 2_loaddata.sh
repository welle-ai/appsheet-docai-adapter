TOKEN=$(gcloud auth print-access-token)
export TOPIC=documents
export GOOGLE_CLOUD_PROJECT=$(gcloud config get project)

set +e

COUNTER=0

while [ $COUNTER -le 10 ]
do
    RESULT=$(curl --location --request POST "https://firestore.googleapis.com/v1/projects/$GOOGLE_CLOUD_PROJECT/databases/(default)/documents/$TOPIC?documentId=b78dfdb" \
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/json" \
    --data-raw "{
        'fields': {
            'id': {
                'stringValue': 'b78dfdb'
            },
            'dateTime': {
                'stringValue': '8/9/2023 9:38:51 AM'
            },
            'file': {
                'stringValue': '/testdoc.pdf'
            },
            'description': {
                'stringValue': 'Filing form.'
            },
            'formFields': {
                'stringValue': 'field1: value1'
            },
            'formThumbnail': {
                'stringValue': '/thumbnail.png'
            },
            'totalFields': {
                'integerValue': '12'
            },
            'filledFields': {
                'integerValue': '8'
            }
        }
    }")

    if [[ "$RESULT" == *error* ]]
    then
        COUNTER=$(( $COUNTER + 1 ))
        echo "Error detected, waiting 10s and then retry $COUNTER of 11 tries..."
        sleep 10s
    else
        COUNTER=11
        echo 0
    fi
done