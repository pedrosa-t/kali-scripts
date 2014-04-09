#!/bin/bash
. helper.sh

install_devel(){

    print_status "Installing development tools and environment"
    apt-get install -y git git-core subversion mercurialm-a prepare build-essential module-assistantlibncurses5-dev zlib1g-dev gawk flex gettext \
    gcc gcc-multilib dkms make linux-headers-$(uname -r) autoconf automake libssl-dev \
    kernel-package ncurses-dev fakeroot bzip2 linux-source
    success_check


    if ask "Install MinGW compiler+tools?" Y; then
        apt-get install -y binutils-mingw-w64 gcc-mingw-w64 mingw-w64 mingw-w64-dev
    fi
}

install_packages(){
    if ask "Install common tools (mostly fixes and essentials) ?" Y; then
        print_status "Installing armitage, mimikatz, unicornscan, and zenmap.."
        apt-get -y install armitage mimikatz unicornscan zenmap
        success_check
        print_notification "Newly installed tools should be located on your default PATH."

        print_status "Fixing wash"
        apt-get -y install libsqlite3-dev
        mkdir -p /etc/reaver

        print_status "Adding some essential packages."
        apt-get install -y cifs-utils ibssl-dev hostapd ipcalc cmake cmake-data \
        emacsen-common libltdl-dev libpcap0.8-dev libtool libxmlrpc-core-c3 arp-scan filezilla gedit recon-ng xdotool \
         curl build-essential openssl libreadline6 libreadline6-dev git-core zlib1g zlib1g-dev \
        libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev bison libmysqlclient-dev libmagickcore-dev \
        libmagick++-dev libmagickwand-dev libnetfilter-queue-dev autotools-dev cdbs check checkinstall dctrl-tools debian-keyring \
        devscripts dh-make diffstat dput equivs libapt-pkg-perl libauthen-sasl-perl libclass-accessor-perl libclass-inspector-perl \
        libcommon-sense-perl libconvert-binhex-perl libcrypt-ssleay-perl libdevel-symdump-perl libfcgi-perl libhtml-template-perl \
        libio-pty-perl libio-socket-ssl-perl libio-string-perl libio-stringy-perl libipc-run-perl libjson-perl libjson-xs-perl libmime-tools-perl\
        libnet-libidn-perl libnet-ssleay-perl libossp-uuid-perl libossp-uuid16 libparse-debcontrol-perl libparse-debianchangelog-perl \
        libpod-coverage-perl libsoap-lite-perl libsub-name-perl libtask-weaken-perl libterm-size-perl libtest-pod-perl \
        libxml-namespacesupport-perl libxml-sax-expat-perl libxml-sax-perl libxml-simple-perl libyaml-syck-perl \
        nautilus-open-terminal lintian lzma patchutils strace wdiff linux-headers-`uname -r` winetricks shellnoob

        print_status "Installing shell tools.."
        apt-get install -y terminator zip gnome-tweak-tool htop mc synapse ack-grep netcat-openbsd xsel screen

        print_status "Installing ARP tools"
        apt-get install -y arp-scan arpalert arping arpwatch

        print_status "Installing unpackers.."
        apt-get -y install unace rar unrar p7zip zip unzip p7zip-full p7zip-rar sharutils uudeview mpack arj cabextract file-roller
    fi

    if ask "Install pip & python modules" Y; then
        apt-get -y install python-setuptools python-pip python-twisted python-virtualenv idle idle3 python-qt4
        pip install shodan mysql-python python-ntlm
    fi

    if ask "Do you want to install RVM ands set ruby-1.9.3 to default?" Y; then
        curl -L https://get.rvm.io | bash -s stable
        source /usr/local/rvm/scripts/rvm
        rvm install 1.9.3
        rvm use 1.9.3 --default

        # This loads RVM into a shell session.
        #echo [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" >> ~/.bashrc
        echo source /usr/local/rvm/scripts/rvm >> ~/.bashrc
    fi

    if ask "Do you want to install ruby and extras?" Y; then
        # This tells RubyGems to not generate documentation for every library it installs.
        echo "gem: --no-rdoc --no-ri" > ~/.gemrc

        apt-get -y install ruby-full ruby-dev libpcap-ruby libpcap-dev libsp-gxmlcpp-dev libsp-gxmlcpp1 libxslt1.1 libxslt1-dev libxrandr-dev libfox-1.6-dev
        update-alternatives --config ruby

        gem install bundler risu ffi multi_json childprocess selenium-webdriver mechanize fxruby net-http-digest_auth pcaprub \
        net-http-persistent nokogiri domain_name unf webrobots ntlm-http net-http-pipeline nfqueue pry colorize mechanize
    fi

    if ask "Do you want to install chromium (and allowing run as root) ?" Y; then
        apt-get install -y chromium
        echo "# simply override settings above" >> /etc/chromium/default
        echo 'CHROMIUM_FLAGS="--password-store=detect --user-data-dir"' >> /etc/chromium/default
    fi

    if ask "Add 'add-apt-repository' script (needed for OracleJDK 7 installation) ?" Y; then
        print_status "Downloading to /usr/sbin/add-apt-repository.."
        wget http://blog.anantshri.info/content/uploads/2010/09/add-apt-repository.sh.txt -O /usr/sbin/add-apt-repository
        chmod o+x /usr/sbin/add-apt-repository
        #chown root:root /usr/sbin/add-apt-repository
        echo "Now try to exec: 'add-apt-repository ppa:webupd8team/java' for example"

        if ask "Install OracleJDK 7" Y; then
            add-apt-repository ppa:webupd8team/java
            apt-get update -y
            #TODO: Can we agree the license in auto mode?
            apt-get install oracle-java7-installer -y
        fi
    fi

    if ask "Do you want to install the flash player?" Y; then
        apt-get -y install flashplugin-nonfree
    fi

    # Kali Cisco VPN Installer based on https://github.com/captainhooligan/Kali-Cisco-VPN
    # TODO: add wget Cisco-VPN.tar.gz
    if ask "Install Cisco VPN?" Y; then
        wget https://github.com/captainhooligan/Kali-Cisco-VPN/raw/master/Cisco-VPN.tar.gz -O /tmp/Cisco-VPN.tar.gz
        cd /tmp

        print_notofocation "Setting up folders..."
        INSTALLDIR=`pwd`
        print_notofocation "Extracting Files..."

        tar xf Cisco-VPN.tar.gz
        cd VPN
        tar xf vpnclient-linux-x86_64-4.8.02.0030-k9.tar.gz

        print_notofocation "Ensuring Kernel Sources are prepared..."
        apt-get install linux-headers-$(uname -r)
        cd /usr/src/linux-headers-$(uname -r)
        cp -rf include/generated/* include/linux
        cd $INSTALLDIR/VPN/vpnclient

        print_notofocation "Applying Patches..."
        patch < ../ciscovpn-kali.patch

        print_notofocation "Compiling and installing Cisco VPN. Please be patient and answer all on screen questions."
        ./vpn_install
    fi

    #TODO: check this shit.
    if ask "Do you want to configure /var/www/tools?" Y; then
        apt-get -y install windows-binaries
        mkdir -p /var/www/tools/shells && chmod -R 755 /var/www/tools
        cp /usr/share/windows-binaries/{nc.exe,plink.exe,vncviewer.exe,wget.exe} /var/www/tools/
        wget -c http://winscp.net/download/winscp514.zip -O /tmp/winscp514.zip && unzip /tmp/winscp514.zip
        cp /tmp/WinSCP.exe /var/www/tools/scp.exe
        rm /tmp/winscp*
        rm /tmp/readme.txt
        rm /tmp/WinSCP*
    fi

    if ask "Do you want to install meld (graphical diff tool)?" Y; then
        apt-get -y install meld
        gconftool-2 --type bool --set /apps/meld/show_line_numbers true
        gconftool-2 --type bool --set /apps/meld/show_whitespace true
        gconftool-2 --type bool --set /apps/meld/use_syntax_highlighting true
        gconftool-2 --type int --set /apps/meld/edit_wrap_lines 2
    fi

    if ask "Do you want to install pidgin and an OTR chat plugin?" Y; then
        apt-get -y install pidgin pidgin-otr
    fi
}

install_misc(){


    if ask "Install Jetbrains PyCharm Community Edition?" N; then
        wget http://download.jetbrains.com/python/pycharm-community-3.1.1.tar.gz -O /tmp/pycharm-community-3.1.1.tar.gz
        cd /opt
        tar xzvf /tmp/pycharm-community-3.1.1.tar.gz

        #TODO: add java -version check
        print_status "Not complete yet..."
        pause
    fi


    if ask "Install Dropbox? " Y; then
        apt-get install -y nautilus-dropbox
    fi

}

cleanup(){
    if ask "Clean up?" Y; then
        apt-get -y autoremove && apt-get -y clean
    fi
}

# Main code here.
check_euid
install_devel
install_packages
install_misc
cleanup