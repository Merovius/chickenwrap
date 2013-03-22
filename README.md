chickenwrap - modify i3bar's input with custom CHICKEN-code
===========================================================

chickenwrap is a toyproject to learn CHICKEN scheme.
I thought about an easy, obviously functional task with real-world-applications
to get a little used to the language and this is, what I came up with.

This also means that it will most likely never be completed and I probably
won't accept feature-requests.

The idea
--------

I want to give an i3-user the easy possibility to wrap i3status' output (or
more precisely modify i3bars' input on-the-fly) by giving them a framework with
easy to use functions. For this the user can write own CHICKEN-scripts, which
will be provided with a few hooks and functions to manipulate the output. All
these scripts are then executed by chickenwrap and the output of i3status or a
similar command will be filtered through all of them.

Current state
-------------

The current state is Proof-of-concept-like. Only one hook is provided and
chickenwrap is not integrated in the way i3bar/i3status are coupled, so you can
only just test it by piping i3status output through chickenwrap. Scripts are
already loaded, but there is no error- or sanity-checking of any kind.

Trying it
---------

    $ git clone git://github.com/Merovius/chickenwrap.git
    $ cd chickenwrap
    $ mkdir -p ~/.config/chickenwrap
    $ cp examples/ipv6_this_is_a_test.scm ~/.config/chickenwrap
    $ csc chickenwrap.scm
    $ i3status -c examples/i3status.conf | ./chickenwrap
