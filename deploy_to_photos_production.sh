while true; do
    echo "WARNING: you are about to deploy to photos production."
    read -p "Enter the name of the tag to install from: " tag
    read -p "Confirm the tag by typing again: " ctag
    case $tag in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
