Code from blog post: http://matt.weppler.me/2013/07/19/lets-build-a-sinatra-app.html

Set following ENV variables:

SESSION_COOKIE_SECRET
JWT_SECRET
JWT_ISSUER

To run server: JWT_SECRET=<someawesomesecret> JWT_ISSUER=<moneyapi.com> rackup