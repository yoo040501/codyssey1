### 7.1 따옴표가 닫히지 않아 명령 입력이 종료되지 않은 문제

#### 문제

다음 명령을 잘못 입력한 후 셸에 `dquote>`가 표시되고 명령이 종료되지 않았다.

```bash
echo ""Docker Practice" > note.txt
```

```text
dquote>
```

#### 원인 가설

큰따옴표의 개수가 맞지 않아 zsh가 문자열이 아직 끝나지 않은 것으로 해석했다고 판단했다.

#### 확인

명령을 다시 확인한 결과 문자열 시작과 끝의 따옴표가 올바르게 짝을 이루지 않은 것을 확인했다.

#### 해결

`Ctrl+C`를 눌러 진행 중인 입력을 취소한 뒤 따옴표를 올바르게 수정하여 다시 실행했다.

```bash
echo "Docker Practice" > note.txt
cat note.txt
```

```text
Docker Practice
```

### 7.2 `rmdir` 대상 누락 문제

#### 문제

삭제할 디렉터리 이름 없이 `rmdir`만 실행하여 사용법 안내가 출력되었다.

```bash
rmdir
```

```text
usage: rmdir [-pv] directory ...
```

#### 원인 가설

`rmdir` 명령에는 삭제할 디렉터리 경로가 반드시 필요하다고 판단했다.

#### 확인

`ls`로 확인한 결과 `archive` 디렉터리가 삭제되지 않고 남아 있었다.

```text
archive
empty.txt
note.txt
```

#### 해결

삭제할 디렉터리 이름을 인자로 지정했다.

```bash
rmdir archive
ls
```

```text
empty.txt
note.txt
```

### 7.3 중지된 컨테이너에서 `docker exec`를 실행할 수 없는 문제

#### 문제

`ubuntu-lab`을 중지한 후 `docker exec`를 실행했지만 오류가 발생했다.

```bash
docker stop ubuntu-lab
docker exec -it ubuntu-lab bash
```

```text
Error response from daemon: container 7ab8decd9aba... is not running
```

#### 원인 가설

`docker exec`는 실행 중인 컨테이너에 새로운 프로세스를 추가하는 명령이므로 중지된 컨테이너에서는 사용할 수 없다고 판단했다.

#### 확인

다음 명령으로 컨테이너 상태를 확인했다.

```bash
docker ps -a --filter name=ubuntu-lab
```

`ubuntu-lab`이 `Exited` 상태인 것을 확인했다.

#### 해결

컨테이너를 먼저 시작한 후 `docker exec`를 실행해야 한다.

```bash
docker start ubuntu-lab
docker exec -it ubuntu-lab bash
```

### 7.4 `sleep infinity` 프로세스에 attach한 후 입력할 수 없는 문제

#### 문제

다음 명령으로 `ubuntu-lab`에 연결했지만 화면에 아무것도 표시되지 않고 명령을 입력할 수 없었다.

```bash
docker attach ubuntu-lab
```

#### 원인 가설

`docker attach`는 새로운 셸을 실행하는 명령이 아니라 컨테이너의 기존 메인 프로세스에 연결하는 명령이다.

`ubuntu-lab`의 메인 프로세스는 Bash가 아닌 `sleep infinity`이므로 사용자 명령을 처리하거나 결과를 출력하지 않는다고 판단했다.

#### 확인

다음 명령으로 메인 프로세스를 확인했다.

```bash
docker ps
```

```text
IMAGE          COMMAND            NAMES
ubuntu:24.04   "sleep infinity"   ubuntu-lab
```

#### 해결

`Ctrl+P`, `Ctrl+Q`를 순서대로 눌러 컨테이너를 종료하지 않고 연결을 해제했다.

컨테이너 내부에서 명령을 실행할 때는 `attach` 대신 `exec`를 사용했다.

```bash
docker exec -it ubuntu-lab bash
```

[README로 돌아가기](../README.md)