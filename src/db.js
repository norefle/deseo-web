const MongoDb = require("mongodb").MongoClient;

const DB_URL = process.env.DB_URL;
const DB_USER = process.env.DB_USER;
const DB_PASSWD = process.env.DB_PASSWD;

function client() {
    let url = `mongodb://${DB_USER}:${DB_PASSWD}@${DB_URL}`;
    return MongoDb.connect(url);
}

function collection(name, callback) {
    return client().then((db) => {
        return callback(db.collection(name))
            .then((data) => {
                db.close();
                return data;
            }).catch((error) => {
                db.close();
                return error;
            });
    });
}

function listItems(user) {
    return collection("lists", (table) => {
        return table.find({ user }).toArray();
    });
}

function createItem(user, item) {
    return collection("lists", (table) => {
        item.user = user;
        return table.insertOne(item);
    });
}

module.exports = {
    listItems: listItems,
    createItem: createItem
};