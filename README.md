# Compute for Humanity (Server)

Compute for Humanity is an OS X app and server program that work together to
raise money for charities using low-energy distributed cryptocurrency mining.

Learn more at [www.computeforhumanity.org](http://www.computeforhumanity.org).

----

This repository includes both a Rails server and several rake tasks to run the
automated transaction and donation processes.

The schedule of rake tasks is:

- 14:00 UTC (daily): `rake philanthropist:donate`
- 14:30 UTC (daily): `rake philanthropist:confirm`
- 15:00 UTC (daily): `rake philanthropist:exchange`

The order of these tasks is the opposite in which value moves through the
system. While this lengthens the process of donating, it allows for more time to
investigate or intervene in case something goes wrong.

### Contributing

Contributions are more than welcome! Take a look at the outstanding Issues to get a sense of some ideas, or feel free to open your own Issue. The general protocol:

1. Indicate your desire to work on something via GitHub Issues.
2. Fork the app.
3. Run `bundle install` and then `overcommit --install`.
4. Submit a pull request.
5. Once your changes are approved, they'll be merged, and (if you like) you'll be added to the [contributors list](https://github.com/ComputeForHumanity/compute-for-humanity-server/blob/master/CONTRIBUTORS.md)!

Note that this project uses [Overcommit](https://github.com/brigade/overcommit)
to ensure a reasonable level of code style standardization and coding best
practices.

### License

Everything in this repository is released under the
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

### Mandatory Disclaimer

This application is not directly supported by Dwolla Corp. Dwolla
Corp. makes no claims about this application. This application is not
endorsed or certified by Dwolla Corp.
