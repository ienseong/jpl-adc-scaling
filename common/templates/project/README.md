Next Steps
==========

Your initial project has been created in the current directoy.  Perform the
following steps to complete the creation of your new project.

Add to GitHub
-------------

1. [Create a new repository on GitHub][1].

   Do not initialize the new repository with README or gitignore files.

2. Push your new project to GitHub by running the following commands in `$SBOX`

       git remote add origin <remote-repository-url>
       git push -u origin master

Create a Project Sandbox
----------------------

Create a project sandbox from your GitHub repository using the following
command:

    sba clone <org/repo>

Example:

To create a project sandbox for the [m2020-vce-fpga/cvac][2] GitHub repostory,
the command is:

    sba clone m2020-vce-fpga/cvac

Modify the README
-----------------

Modify the README to tell others about it and how to contribute.

[1]: https://help.github.com/articles/creating-a-new-repository
[2]: https://github.jpl.nasa.gov/m2020-vce-fpga/cvac
