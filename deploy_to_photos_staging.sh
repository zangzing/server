ey deploy -e photos_stag -v -m 'rake build:db'
ey recipes apply -e sandbox
echo "Deployed to Sandbox"
