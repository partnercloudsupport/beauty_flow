import * as admin from 'firebase-admin';

export const getSavedModule = function(req, res) {
    const uid = String(req.query.uid);

    async function compileFeedPost() {
  
        const postsIds = await getPostIds(uid, res) as any;
    
        let listOfPosts = await getAllPosts(postsIds, res);
    
        listOfPosts = [].concat.apply([], listOfPosts); // flattens list
    
        res.send(listOfPosts);
      }
      
      compileFeedPost().then().catch();

}

async function getAllPosts(postsIds , res) {
    const listOfPosts = [];
  
    for (const postid in postsIds){
        listOfPosts.push( await getUserPosts(postsIds[postid], res));
    }
    return listOfPosts; 
}


function getUserPosts(postid, res){
    const posts = admin.firestore().collection("beautyPosts").where("postId", "==", postid);
  
    return posts.get()
    .then(function(querySnapshot) {
        const listOfPosts = [];
  
        querySnapshot.forEach(function(doc) {
            listOfPosts.push(doc.data());
        });
  
        return listOfPosts;
    })
}


function getPostIds(uid, res){
    const doc = admin.firestore().doc(`users/${uid}`);
    return doc.get().then(snapshot => {
      const savedData = snapshot.data().savedPostIds;
      
      const saved_list = [];
  
      for (const saved in savedData) {
        if(savedData[saved] === true) {
            saved_list.push(saved);
        }
      }
      return saved_list; 
  }).catch(error => {
      res.status(500).send(error)
    })
}