import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { getFeedModule } from "./getFeed"
import { getSavedModule } from './getSaved';
admin.initializeApp();

export const getFeed = functions.https.onRequest((req, res) => {
  getFeedModule(req, res);
})

export const getSaved = functions.https.onRequest((req, res) => {
  getSavedModule(req, res);
})