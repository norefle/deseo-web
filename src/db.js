const MongoDb = require("mongodb").MongoClient;

const DB_URL = process.env.DB_URL;
const DB_USER = process.env.DB_USER;
const DB_PASSWD = process.env.DB_PASSWD;

function list(user) {
    let url = `mongodb://${DB_USER}:${DB_PASSWD}@${DB_URL}`;
    return MongoDb.connect(url)
        .then((db) => {
            return new Promise((resolve, reject) => {
                db.collection("lists")
                    .find({ user })
                    .toArray((err, docs) => {
                        db.close();
                        if (err) {
                            reject(err);
                        } else {
                            resolve(docs);
                        }
                    });
            });
        }).then((data) => {
            return data;
        }).catch((error) => {
            console.error("DB failure:", error);
        });
}

module.exports = {
    list: list
};