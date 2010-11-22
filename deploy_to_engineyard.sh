ey deploy -e dev -v -m 'rake build:db'
ey recipes apply -e dev
echo "Deployed"
