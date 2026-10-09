import subprocess
import functools


class ConverterError(Exception):
    pass


def _is_ffprobe_command(template: tuple[str, ...]) -> bool:
    return template[0] == "ffprobe"


def main(command: tuple[str, ...]):
    if not _is_ffprobe_command(command):
        return False
    try:
        raw_data = subprocess.run(command, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as exc:
        raise ConverterError(f"Error running: {command}: {exc.stderr}") from exc
    return raw_data


if __name__ == "__main__":
    main(command=("a", "b"))
