const Cheerio = require("cheerio");
const Request = require("request-promise-native");

const URL_REGEX = {
    DE: /^(?:https|http):\/\/(?:www\.)?amazon.de\/dp\/([A-Z0-9]+)\/?$/
};

const PRICE_REGEX = {
    DE: /^EUR\s*([0-9]+.?[0-9]*)$/
};

function checkUrl(region, url) {
    let regex = URL_REGEX[region];
    return regex
        ? regex.test(url)
        : false;
}

function parse(region, url) {
    return Request.get(url + "?language=en_GB").then((data) => {
        let $ = Cheerio.load(data);
        let title = $("#productTitle").text();
        let priceString = $("#priceblock_ourprice").text();
        let price = PRICE_REGEX[region].exec(priceString);
        price = price ? price[1] : null;
        let image = $("#landingImage").attr("src");
        return {
            title: title ? title.trim() : null
            , price: price ? Math.ceil(price * 100) : null
            , image: image ? image.trim() : null
        };
    });
}

module.exports = {
    checkUrl: checkUrl
    , parse: parse
}