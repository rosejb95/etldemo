manifest_temp_file=$(mktemp)
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export $( cat $script_dir/runner.env | xargs )
export image_tag=$DEFAULT_IMAGE_TAG
export branch=$DEFAULT_BRANCH

while getopts t:n:b:c:i: opt; do
  case $opt in 
    t) export image_tag=$OPTARG ;;
    n) export name=$OPTARG ;;
    b) export branch=$OPTARG ;;
    c) export command=$OPTARG ;;
    i) interactive=$OPTARG ;;
    *) echo 'Unexpected argument found' >&2; exit 1
  esac
done

if [ $interactive != 'yes' ] && [ -z command ];
then
  echo "Either -c (command) or -i (interactive) is required." >&2
  exit 1
fi

if [ $interactive == 'yes' ];
then
  template_file_name="$script_dir/bdb_box_template.yml"
else
  template_file_name="$script_dir/bdb_job_template.yml"
fi

# Values are set via environment variables.
j2 $template_file_name >$manifest_temp_file

# Start the box -- TODO: check failure behavior.
kubectl apply -f $manifest_temp_file

exit