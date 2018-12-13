# Serverless OpenHack Challenge - Finish the Ice Cream Ratings API

## Background

A very common scenario for serverless is to use it to implement or extend an API as the backend for a website or mobile application. Some companies also sell their API as a product, or expose it to partners for business to business integration.

Serverless functions should be stateless and idempotent if possible. So a best practice for managing state for serverless architectures is to rely on other services to read and write state. For example, a database like Azure Cosmos DB.

In this challenge you will create a new Logic App to extend the existing Soft Serverless Ice Cream API.

## Challenge

Soft Serverless Ice Cream are creating a consumer facing website and mobile application that will allow their end customers to rate their ice cream.

The Ratings functions your are creating in this challenge are part of a larger API that Soft Serverless Ice Cream wants to expose to customers. This will be used by the consumer facing ice cream ratings section of a website and mobile app being built by another team in the company.

Three Azure Functions have already been created for getting info about Users and Products. These are the three functions that already:

* Get Products https://serverlessohlondonproduct.azurewebsites.net/api/GetProducts

* Get Product (expects a `productid` query parameter)
https://serverlessohlondonproduct.azurewebsites.net/api/GetProduct

* Get User (expects a `userid` query parameter)
https://serverlessohlondonuser.azurewebsites.net/api/GetUser

You now should create a Azure Logic App in your subscription that will implement the Ice Cream Ratings part of the API. Your challenge is to define, create and deploy three API endpoints.

* `CreateRating` (POST)

* `GetRating` (GET)

* `GetRatings` (GET)

For data storage, use a data service like Cosmos DB in your Azure subscription to store and retrieve the ratings.

### CreateRating

The `CreateRating` function should accept a JSON document that looks like the following:

```JSON
{
    "userid": "cc20a6fb-a91f-4192-874d-132493685376",
    "productid": "4c25613a-a3c2-4ef3-8e02-9c335eb23204",
    "timestamp": "Wed, 21 Mar 2018 13:00:38 GMT",
    "rating": "7",
    "locationname": "Mary's ice cream shop",
    "usernotes": "I really like the subtle notes of orange in this ice cream, great to see this very different flavor!"
}
```

This `CreateRating` function must call the existing Get User and Get Product functions to validate that the `userid` and the `productid` passed in are valid.

### GetRating

`GetRating` should accept a `ratingid` as an input via query string and return the rating that matches that ID.

### GetRatings

`GetRatings` should accept `userid` as input via query string and return all the ratings for that user ID.

## Success Criteria
In the chat window, provide with your API endpoint root URL for validation.