import * as admin from 'firebase-admin';


export const getFeedModule = function(req, res) {
    const uid = String(req.query.uid);
    
    async function compileFeedPost() {
      const following = await getFollowing(uid, res) as any;
  
      let listOfPosts = await getAllPosts(following, res);
  
      listOfPosts = [].concat.apply([], listOfPosts); // flattens list
  
      res.send(listOfPosts);
    }
    
    compileFeedPost().then().catch();
}
  
async function getAllPosts(following, res) {
    const listOfPosts = [];
  
    for (const user in following){
        listOfPosts.push( await getUserPosts(following[user], res));
    }
    return listOfPosts; 
}
  
function getUserPosts(userId, res){
    const posts = admin.firestore().collection("beautyPosts").where("ownerId", "==", userId)
  
    return posts.get()
    .then(function(querySnapshot) {
        const listOfPosts = [];
  
        querySnapshot.forEach(function(doc) {
            listOfPosts.push(doc.data());
        });
  
        return listOfPosts;
    })
}
  
  
function getFollowing(uid, res){
    const doc = admin.firestore().doc(`users/${uid}`)
    return doc.get().then(snapshot => {
      const followings = snapshot.data().following;
      
      const following_list = [];
  
      for (const following in followings) {
        if (followings[following] === true){
          following_list.push(following);
        }
      }
      return following_list; 
  }).catch(error => {
      res.status(500).send(error)
    })
}