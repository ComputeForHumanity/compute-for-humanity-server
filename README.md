# Compute for Humanity (Server)

Compute for Humanity is an OS X app and server program that work together to raise money for charities using low-energy distributed cryptocurrency mining.

Learn more at [www.computeforhumanity.org](http://www.computeforhumanity.org).

----

This repository includes both a Rails server and several rake tasks to run the automated transaction and donation processes.

The schedule of rake tasks is:
- 14:00 UTC (daily): `rake philanthropist:donate`
- 14:30 UTC (daily): `rake philanthropist:confirm`
- 15:00 UTC (daily): `rake philanthropist:exchange`

#### Mandatory Disclaimer

This application is not directly supported by Dwolla Corp. Dwolla
Corp.
makes no claims about this application. This application is not
endorsed or certified by Dwolla Corp.
