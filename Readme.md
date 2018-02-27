Sitecore Install Framework (SUG CPH March 2018)
=============================================

This is a collection of scripts and documents that will be used to guide the
Sitecore User Group in Copenhagen (March 2018).

If there are questions on guidance of using SIF during the user group, I will
try to provide examples here.

Feel free to use the scripts as you need.

[@Kieranties](https://twitter.com/Kieranties)

Getting Started
===============

To prepare for the user group, read the [prerequisites](/Prerequisites.md) and
gather the assets required for installing sitecore. You can also use the environment
scripts to get up and running quicker.

Environment Setup Scripts
------------------------

The [Environment](/Environment) folder contains scripts to help prepare an
environment for installation.

+ [Server-Setup.ps1](./Environment/Server-Setup.ps1) - Prepares a server where SIF will be executed.
+ [Sql-Setup.ps1](./Environment/Ssql-Setup.ps1) - Enables contained databases on Sql Server.
+ [Solr-Setup.ps1](./Environment/Solr-Setup.ps1) - Installs Solr as a service (Install java jre first!).

Gather the Sitecore assets for install
-------------------------------------

After completing the prerequisites you'll need to download Sitecore to install.

[Download][1] the On Premise packages for XP Scaled and extract the contents.

If you're planning on following along with this repo:

1. Copy all `*.scwdp.zip` files into `<repo>/Packages`
2. Open the `XP1 Configuration files..` zip and copy contents to `<repo>/Configs`
3. Get your license file and place in the root of the repo.

---
License - [MIT](https://kieranties.mit-license.org/)

[1]: https://dev.sitecore.net/Downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Update1.aspx