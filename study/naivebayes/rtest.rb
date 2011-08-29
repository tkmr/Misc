require 'rubygems'
require 'rinruby'
require 'pp'

R.echo(enable = false)

R.eval <<RR
  x <- 1:10
  plot(x)
RR
p R.x

R.y = R.pull "rnorm(1000)"
p R.y.size

R.eval "hist(y)"
gets

R.people = ["tom", "dick", "terry"]

R.echo(true)
R.eval "print(people)"

