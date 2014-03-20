# Searchy

Searchy is a really simple search engine with a good deal of limitations,
writting in [Sinatra](http://sinatrarb.com).

Searchy was written for my Computing Paradigms course, the assignment was to
create a web app in Ruby using Sinatra.

## Limitations

Lets just get these out of the way quickly. Searchy doesn't scale. At all. If
you get more than ~100 pages crawled, it'll take a long time for Searchy to
return results.

There are other limitations, but the big one is that Searchy is size limited.
A much smaller one is that it can't run on Heroku with the production database
unless the page set is kept small due to the DB's row limit.

## Potential Future Work

Searchy is most likely in its final state right now. The assignment has been
turned in, and I don't really care about this implementation. Future work on
creating a search engine would probably be funneled into a completely new system
that isn't written in Ruby, and uses a faster database. It would also probably
be written to be concurrent and distributed from the start.
