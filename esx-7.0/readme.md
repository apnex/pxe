I just thought I'd share a tip for those who are building nested home lab environments at the moment.

I've set up the ability to quickly perform an unattended ESX 7.0 pxe install over the Internet straight from an AWS S3 bucket.
This requires zero local pxe infrastructure - other than outbound internet access.

Brief steps are as follows;
#1 Download tiny 1MB iso @ `http://esx.apnex.io/esx.iso`
#2 Upload the `esx.iso` file to an available Datastore
#3 Create a new blank VM as per normal (manual, script, API etc)
-- Ensure guest os type = "ESX 6.x or later"
-- Ensure boot type = BIOS
-- Ensure you have at least 1 vnic connected to a DHCP enabled network
#4 Create and attach a CDROM referencing the `esx.iso` file from Datastore
#5 Power on the VM
#6 Wait 3 minutes and.. Success!

Makes it easy to script and scale up multiple builds concurrently for your favourite SDDC nested lab.
