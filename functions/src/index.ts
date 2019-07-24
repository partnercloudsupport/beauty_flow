import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { getFeedModule } from "./getFeed"
import { getSavedModule } from './getSaved';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const getFeed = functions.https.onRequest((req, res) => {
  getFeedModule(req, res);
})

export const getSaved = functions.https.onRequest((req, res) => {
  getSavedModule(req, res);
})

export const BookingsendToDevice = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async snapshot => {


    const booking = snapshot.data();

    const querySnapshot = await db
      .collection('users')
      .doc(booking.beautyProId)
      .collection('tokens')
      .get();

    const tokens = querySnapshot.docs.map(snap => snap.id);

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'New Booking',
        body: `you got a booking from ${booking.bookedByDisplayName} for ${booking.style}`,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    return fcm.sendToDevice(tokens, payload);
  });