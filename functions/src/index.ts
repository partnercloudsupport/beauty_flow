import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { getFeedModule } from "./getFeed"
admin.initializeApp();

export const getFeed = functions.https.onRequest((req, res) => {
  getFeedModule(req, res);
})