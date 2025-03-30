# Set the network interface to use.
# You can override this on the command line, e.g., make INTERFACE=eth0 install
INTERFACE ?= eno1

# Read the MAC address from the chosen interface.
MAC := $(shell cat /sys/class/net/$(INTERFACE)/address)

# Default target: run the install target.
all: install

# Generate a new version of the file with the actual MAC address.
50-wol.link.correct: 50-wol.link
	@echo "Injecting MAC address $(MAC) into 50-wol.link..."
	@sed "s/aa:bb:cc:dd:ee:ff/$(MAC)/g" $< > $@

# Install the modified file to /etc/systemd/network/
install: 50-wol.link.correct
	@echo "Copying 50-wol.link.correct to /etc/systemd/network/50-wol.link..."
	@sudo cp $< /etc/systemd/network/50-wol.link

# Optional clean target to remove the generated file.
clean:
	@rm -f 50-wol.link.correct

