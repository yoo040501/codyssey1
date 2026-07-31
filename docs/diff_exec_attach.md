# docker exec와 docker attach 차이

## 1. docker exec

기본 형식은 다음과 같다.

```bash
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

`docker exec`는 실행 중인 컨테이너 내부에 새로운 프로세스를 실행한다. 따라서 어느 컨테이너에서 실행할지와 어떤 프로그램을 실행할지를 모두 지정해야 한다.

```bash
docker exec -it ubuntu-lab bash
```

| 부분 | 의미 |
| --- | --- |
| `-i` | 표준 입력을 열린 상태로 유지 |
| `-t` | 가상 터미널 할당 |
| `ubuntu-lab` | 명령을 실행할 컨테이너 |
| `bash` | 컨테이너 내부에서 새로 실행할 프로그램 |

`bash`는 반드시 사용해야 하는 고정 인자가 아니다. 대화형 셸이 필요해서 실행할 명령으로 Bash를 지정한 것이다.

프로그램을 직접 실행할 수도 있다.

```bash
docker exec ubuntu-lab ls -la
docker exec ubuntu-lab cat /etc/os-release
docker exec ubuntu-lab echo "Hello"
```

리다이렉션이나 파이프 같은 셸 문법을 사용하려면 셸을 직접 실행해야 한다.

```bash
docker exec ubuntu-lab \
  sh -c 'echo "Hello" > /tmp/message.txt'
```

`sh`는 실행할 프로그램이고, `-c`는 뒤의 문자열을 셸 명령으로 해석하라는 `sh`의 옵션이다.

## 2. docker attach

기본 형식은 다음과 같다.

```bash
docker attach [OPTIONS] CONTAINER
```

`docker attach`는 새로운 프로세스를 실행하지 않는다. 컨테이너에서 이미 실행 중인 메인 프로세스의 표준 입력, 표준 출력, 표준 오류에 현재 터미널을 연결한다.

따라서 새로 실행할 프로그램을 지정할 필요가 없으며 컨테이너 이름만 필요하다.

```bash
docker attach ubuntu-attach
```

메인 프로세스가 Bash인 컨테이너에 연결하면 명령을 입력할 수 있다.

```bash
docker run -dit \
  --name ubuntu-attach \
  ubuntu:24.04 \
  bash

docker attach ubuntu-attach
```

메인 프로세스가 `sleep infinity`라면 셸이 아니므로 명령을 입력할 수 없다.

```bash
docker run -dit \
  --name ubuntu-lab \
  ubuntu:24.04 \
  sleep infinity

docker attach ubuntu-lab
```

이 경우 터미널이 멈춘 것처럼 보이지만 실제로는 `sleep infinity`의 입출력에 정상적으로 연결된 상태이다.

컨테이너를 종료하지 않고 연결만 해제하려면 다음 키를 순서대로 입력한다.

```text
Ctrl+P → Ctrl+Q
```

## 3. exec와 attach 비교

| 구분 | `docker exec` | `docker attach` |
| --- | --- | --- |
| 새 프로세스 실행 | 실행함 | 실행하지 않음 |
| 필수 인자 | 컨테이너, 실행 명령 | 컨테이너 |
| 연결 대상 | 새로 실행한 프로세스 | 기존 메인 프로세스 |
| 셸 사용 | `bash`, `sh` 등을 직접 지정 | 메인 프로세스가 셸일 때만 가능 |
| `exit` 결과 | exec 프로세스만 종료 | 메인 프로세스 종료 시 컨테이너도 종료 |
| 주요 용도 | 내부 명령 실행과 디버깅 | 메인 프로세스 입출력 연결 |

## 4. 실습 결과

`ubuntu-lab`은 `sleep infinity`를 메인 프로세스로 실행했다.

```bash
docker exec -it ubuntu-lab bash
```

`exec`로 실행한 Bash에서 `exit`했지만 메인 프로세스는 계속 실행 중이므로 컨테이너가 유지되었다.

반면 메인 프로세스가 Bash인 `ubuntu-attach`에 직접 연결했다.

```bash
docker attach ubuntu-attach
```

Bash에서 `exit`하자 메인 프로세스가 종료되면서 컨테이너도 `Exited (0)` 상태가 되었다.

## 5. 결론

- `exec`는 컨테이너 안에서 새로운 명령을 실행한다.
- `attach`는 이미 실행 중인 메인 프로세스에 연결한다.
- 컨테이너 내부에 새 셸이 필요하면 `docker exec -it CONTAINER bash`를 사용한다.
- 메인 프로세스의 출력과 입력을 직접 확인하려면 `docker attach CONTAINER`를 사용한다.

[README로 돌아가기](../README.md)