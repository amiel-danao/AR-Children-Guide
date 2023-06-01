from firebase_admin import credentials, firestore, initialize_app
from firebase_admin import firestore
from firebase_admin import messaging
from datetime import datetime, timedelta

# Initialize the Firebase Admin SDK
cred = credentials.Certificate('mobile-ar-6984e-firebase-adminsdk-10ozf-929742db4d.json')
initialize_app(cred)

# Initialize Firestore
db = firestore.client()

def on_snapshot(doc_snapshot, changes, read_time):
    for change in changes:
        if change.type.name == 'ADDED':
            doc = change.document
            ticket_data = doc.to_dict()
            print(f"New ticket created with ID: {doc.id}")
    
            # Retrieve the necessary fields from the ticket document
            uid = ticket_data.get('uid')
            parentId = ticket_data.get('parentId')
            username = ticket_data.get('username')

            token_ref = db.collection('Tokens').document(parentId)
            token_doc = token_ref.get()
            if token_doc.exists:
                token_data = token_doc.to_dict()
                rescuer_fcm_token = token_data.get("token")
                print(f"FCM token for rescuer {parentId}: {rescuer_fcm_token}")

                # Compose the FCM notification message
                message = messaging.Message(
                    notification=messaging.Notification(
                        title='Child arrived Notification',
                        body=f'{username} has arrived in their destination',
                    ),
                    data={
                        'uid': uid,
                        'parentId': parentId,
                        'username': username
                    },
                    token=rescuer_fcm_token
                    # topic='ticket_updates',  # Replace with your desired FCM topic
                )

                # Send the FCM notification
                response = messaging.send(message)
                print('FCM notification sent:', response)
                # Perform actions here based on the new ticket document
                # Perform actions here based on the new ticket document

# Create a reference to the "Tickets" collection
notif_ref = db.collection('Notifications')

cutoff_date = datetime.now() + timedelta(minutes=30)

# Filter the query using dateSubmitted field
query = notif_ref.where('dateNotified', '<', cutoff_date)
# Start listening to document creations
doc_watch = query.on_snapshot(on_snapshot)


while True:
    pass