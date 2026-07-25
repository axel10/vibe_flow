import argparse
import os
import shutil
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

DEFAULT_COVER_IMAGE = r"C:\Users\Administrator\Desktop\b19edb574746bcc13eb44cff9fcb9310.jpg"
DEFAULT_OUTPUT_DIR = r"C:\Users\Administrator\Desktop\test_music_100k"
DEFAULT_TOTAL_FILES = 100000
DEFAULT_FILES_PER_FOLDER = 1000
DEFAULT_DURATION = 0.1  # 秒
DEFAULT_BITRATE = "96k"

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass


def create_template_mp3(
    template_path: str, cover_path: str, duration: float, bitrate: str
) -> None:
    """使用 FFmpeg 生成一个包含 96kbps 音频与内嵌封面的基础 MP3 模板文件。"""
    cmd = [
        "ffmpeg",
        "-y",
        "-f",
        "lavfi",
        "-i",
        "anullsrc=r=44100:cl=stereo",
        "-i",
        cover_path,
        "-map",
        "0:a",
        "-map",
        "1:v",
        "-c:a",
        "libmp3lame",
        "-b:a",
        bitrate,
        "-c:v",
        "copy",
        "-metadata:s:v",
        'title="Album cover"',
        "-metadata:s:v",
        'comment="Cover (front)"',
        "-id3v2_version",
        "3",
        "-t",
        str(duration),
        template_path,
    ]
    print(f"[1/3] 正在调用 FFmpeg 生成 {duration}s 基础模板文件: {template_path}...")
    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace"
    )
    if result.returncode != 0:
        raise RuntimeError(f"FFmpeg 生成模板失败:\n{result.stderr}")

    file_size_kb = os.path.getsize(template_path) / 1024
    print(f"[OK] 模板生成成功！单文件大小: ~{file_size_kb:.2f} KB\n")


def copy_file_worker(task):
    src, dst = task
    shutil.copyfile(src, dst)


def generate_files(
    template_path: str, output_dir: str, total_files: int, files_per_folder: int
) -> None:
    """多线程批量复制生成测试目录结构"""
    os.makedirs(output_dir, exist_ok=True)
    print(f"[2/3] 正在规划 {total_files} 个文件的目录结构...")

    tasks = []
    if files_per_folder > 0:
        num_folders = (total_files + files_per_folder - 1) // files_per_folder
        for folder_idx in range(num_folders):
            folder_name = f"Artist_{folder_idx + 1:04d}"
            folder_path = os.path.join(output_dir, folder_name)
            os.makedirs(folder_path, exist_ok=True)

            start_i = folder_idx * files_per_folder
            end_i = min(start_i + files_per_folder, total_files)
            for i in range(start_i, end_i):
                dst = os.path.join(folder_path, f"Track_{i + 1:06d}.mp3")
                tasks.append((template_path, dst))
    else:
        for i in range(total_files):
            dst = os.path.join(output_dir, f"Track_{i + 1:06d}.mp3")
            tasks.append((template_path, dst))

    cpu_count = os.cpu_count() or 4
    max_workers = min(32, cpu_count * 4)
    print(f"[3/3] 开始多线程快速生成 ({max_workers} 个线程并发工作)...")

    start_time = time.time()
    last_print = start_time

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for idx, _ in enumerate(executor.map(copy_file_worker, tasks), 1):
            now = time.time()
            if idx % 10000 == 0 or idx == total_files or (now - last_print) >= 2.0:
                elapsed = now - start_time
                rate = idx / elapsed if elapsed > 0 else 0
                percent = (idx / total_files) * 100
                print(
                    f"进度: {idx}/{total_files} ({percent:.1f}%) | 速度: {rate:.0f} 文件/秒",
                    end="\r",
                    flush=True,
                )
                last_print = now

    total_time = time.time() - start_time
    total_size_mb = (os.path.getsize(template_path) * total_files) / (1024 * 1024)
    print(
        f"\n\n[SUCCESS] 完成！成功在 '{output_dir}' 生成了 {total_files} 个 MP3 文件！"
    )
    print(f"耗时: {total_time:.2f} 秒")
    print(f"预计占用空间: ~{total_size_mb:.2f} MB ({total_size_mb/1024:.2f} GB)")


def main():
    parser = argparse.ArgumentParser(description="FFmpeg 10万音乐测试文件快速生成器")
    parser.add_argument(
        "--cover", default=DEFAULT_COVER_IMAGE, help="封面图片路径"
    )
    parser.add_argument(
        "--output", default=DEFAULT_OUTPUT_DIR, help="输出目录路径"
    )
    parser.add_argument(
        "--count", type=int, default=DEFAULT_TOTAL_FILES, help="要生成的音乐文件总数"
    )
    parser.add_argument(
        "--files-per-folder",
        type=int,
        default=DEFAULT_FILES_PER_FOLDER,
        help="每个子文件夹存放的文件数（设为0则铺平在根目录）",
    )
    parser.add_argument(
        "--duration", type=float, default=DEFAULT_DURATION, help="单个 MP3 时长（秒）"
    )
    args = parser.parse_args()

    if not os.path.isfile(args.cover):
        print(f"[ERROR] 错误: 找不到封面图片文件 '{args.cover}'")
        sys.exit(1)

    template_path = os.path.join(os.getcwd(), "_temp_template.mp3")

    try:
        create_template_mp3(
            template_path, args.cover, duration=args.duration, bitrate=DEFAULT_BITRATE
        )
        generate_files(
            template_path, args.output, args.count, args.files_per_folder
        )
    finally:
        if os.path.exists(template_path):
            try:
                os.remove(template_path)
            except Exception:
                pass


if __name__ == "__main__":
    main()
