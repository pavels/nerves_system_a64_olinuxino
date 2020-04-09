################################################################################
#
# a64servo
#
################################################################################

A64SERVO_SOURCE = master.tar.gz
A64SERVO_SITE = https://github.com/pavels/a64servo/archive
A64SERVO_LICENSE = GPL-3.0
A64SERVO_LICENSE_FILES = LICENSE

$(eval $(kernel-module))
$(eval $(generic-package))
