# IWD configuration for eduroam network
> [!WARNING]  
> This script was designed to work with the `eduroam` and `polimi-protected` networks at Politecnico di Milano, if you are from another university, the configuration file will need to be tweaked.

## Usage:
1. Follow the official instructions in the [official Polimi website](https://www.ict.polimi.it/wifi/permanent-connection/tls-linux/?lang=en), in order to obtain a personal `certificate-XXXXXXXX-XXXXXXXX.p12` file and to download the eduroam cat script.

2. Run the eduroam script to generate the `wpa_supplicant` configuration
   ```shell
   python3 eduroam-linux-PdM-polimi-TLS.py --wpa_conf
   ```

3. Open a terminal window, then clone this repository and `cd` into it
    ```shell
    git clone https://github.com/collodel/iwd-eduroam-config.git
    cd iwd-eduroam-config
    ```

4. In the terminal window, copy `ca.pem` and `user.p12` from `~/.config/cat_installer` to the current directory:
    ```shell
    cp ~/.config/cat_installer/ca.pem ~/.config/cat_installer/user.p12 .
    ```

5. Execute the configuration script
    ```shell
    ./create_config.sh <person_code> ./user.p12 <password_of_p12_cert_file>
    ```

6. Move the required files to `/var/lib/iwd`
    ```shell
    sudo mv -vn eduroam.8021x eduroam.crt.pem eduroam.key.pem /var/lib/iwd/
    sudo mv -vn ca.pem /var/lib/iwd/eduroam.pem
    sudo cp -vn /var/lib/iwd/eduroam.8021x /var/lib/iwd/polimi-protected.8021x # needed for the polimi-protected network
    ```

7. Fix the permissions (if needed)
    ```shell
    sudo chown root:root eduroam.8021x eduroam.crt.pem eduroam.key.pem eduroam.pem polimi-protected.8021x
    ```

8. Connecting to either network should be working now!

## Notes:
- The main problem in configuring `eduroam` with TLS arises when using the `.p12` file, that contains at the same time both the user certificate and the private key.
This script mainly extracts these two different files from the `.p12` file in order for iwd to be able to use them separately (TODO: there seems to exist `EAP-TLS-ClientKeyBundle` as an option [here](https://iwd.wiki.kernel.org/networkconfigurationsettings) that takes the `.p12` file directly).
- The eduroam configuration with TTLS seems to work only with `polimi-protected`, so I think this is the best way to configure `eduroam` at Polimi.
