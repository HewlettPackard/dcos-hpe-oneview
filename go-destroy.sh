rm /root/log/dcos_play.log
ansible-playbook ov_dcos_decompose_all.yml -vvv -e "ansible_python_interpreter=/usr/local/bin/python2.7"
