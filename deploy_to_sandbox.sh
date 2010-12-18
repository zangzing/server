ey deploy -e sandbox -v -m 'rake build:db'
ey recipes apply -e sandbox
echo "Deployed to Sandbox"
