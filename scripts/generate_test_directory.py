import argparse
import os
import random
import re
import struct
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

DEFAULT_COVER_IMAGE = r"C:\Users\Administrator\Desktop\b19edb574746bcc13eb44cff9fcb9310.jpg"
DEFAULT_OUTPUT_DIR = r"C:\Users\Administrator\Desktop\test_music_100k"
DEFAULT_TOTAL_FILES = 100000
DEFAULT_SONGS_PER_ARTIST = 100
DEFAULT_SONGS_PER_ALBUM = 20
DEFAULT_DURATION = 0.1  # 秒
DEFAULT_BITRATE = "96k"

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# ----------------- 丰富的随机名称词库 -----------------
ARTIST_ADJECTIVES = [
    "Lunar", "Solar", "Velvet", "Silent", "Neon", "Electric", "Golden", "Cosmic",
    "Astral", "Shadow", "Crystal", "Midnight", "Infinite", "Crimson", "Ethereal",
    "Aurora", "Cyber", "Starlight", "Radiant", "Fading", "Mystic", "Echoing",
    "Floating", "Silver", "Amber", "Vivid", "Hollow", "Vibrant", "Chilling",
    "Savage", "Gentle", "Dynamic", "Static", "Zenith", "Glitch", "Retro",
    "Breeze", "Phantom", "Prism", "Subtle", "Luminous", "Horizon", "Distant"
]

ARTIST_NOUNS = [
    "Echo", "Horizon", "Voyager", "Dreamer", "Nomad", "Pulse", "Wanderer",
    "Symphony", "Orchestra", "Collective", "Project", "Ensemble", "Tide",
    "Drifter", "Pioneer", "Echoes", "Mirage", "Shadows", "Waves", "Aura",
    "Vanguard", "Haven", "Odyssey", "Monolith", "Quartet", "Trio", "Duo",
    "Vibration", "Beacon", "Chronicle", "Nebula", "Specter", "Artifact"
]

FIRST_NAMES = [
    "Liam", "Noah", "Oliver", "James", "Elijah", "William", "Henry", "Lucas",
    "Benjamin", "Theodore", "Mateo", "Levi", "Sebastian", "Daniel", "Jack",
    "Alexander", "Owen", "Asher", "Samuel", "Ethan", "Leo", "Jackson",
    "Olivia", "Emma", "Charlotte", "Amelia", "Sophia", "Isabella", "Ava",
    "Mia", "Evelyn", "Luna", "Harper", "Camila", "Sofia", "Aria", "Ella",
    "Chloe", "Penelope", "Layla", "Mila", "Nora", "Hazel", "Aurora", "Elena",
    "Kaito", "Ren", "Haruto", "Yuki", "Sakura", "Hana", "Mei", "Aoi",
    "Chen", "Wei", "Lin", "Yuxuan", "Zimo", "Jia", "An", "Shuo"
]

LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
    "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
    "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
    "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark",
    "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King",
    "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green",
    "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell",
    "Vance", "Rivers", "Sterling", "Cross", "Mercer", "Blackwood", "Winters"
]

ALBUM_THEMES = [
    "Reverie", "Odyssey", "Chronicles", "Memories", "Reflections", "Labyrinth",
    "Moments", "Fragments", "Dimensions", "Whispers", "Echoes", "Visions",
    "Symphonies", "Paradigms", "Illusions", "Tides", "Skies", "Resonance",
    "Horizons", "Journeys", "Passages", "Nocturne", "Serenade", "Afterglow",
    "Eclipse", "Arrival", "Departure", "Genesis", "Exodus", "Continuum",
    "Paradox", "Euphoria", "Solitude", "Metamorphosis", "Threshold"
]

ALBUM_CONNECTORS = [
    "of", "in", "beyond", "under", "through", "across", "into", "towards"
]

TRACK_WORDS_1 = [
    "Dancing with", "Searching for", "Lost in", "Escape from", "Walking through",
    "Staring at", "Falling into", "Voices of", "Flight of", "Tears of",
    "Call of", "Road to", "Bridge to", "Gateway to", "Return to", "Light of",
    "Breath of", "Secrets of", "Whisper of", "Shadow of", "Path of"
]

TRACK_WORDS_2 = [
    "The Moon", "The Stars", "Eternity", "Silence", "The Rain", "The Ocean",
    "Tomorrow", "Yesterday", "The Unknown", "The Void", "Midnight", "Sunrise",
    "Sunset", "The Wind", "Memory", "Paradise", "The Clouds", "The Storm",
    "The Flame", "The Horizon", "Neon City", "Deep Space", "Winter", "Spring"
]

TRACK_SINGLE_NOUNS = [
    "Awakening", "Arrival", "Departure", "Ascension", "Elevation", "Drifting",
    "Flow", "Glow", "Serenity", "Sanctuary", "Illumination", "Reminiscence",
    "Nostalgia", "Cascade", "Solace", "Clarity", "Ignition", "Velocity",
    "Halcyon", "Zenith", "Lucid", "Timeless", "Pulse", "Rhythm", "Frequency"
]


def sanitize_filename(name: str) -> str:
    """清理文件名中的非法字符以适配 Windows 文件系统"""
    cleaned = re.sub(r'[\\/*?:"<>|]', "", name).strip(". ")
    return cleaned if cleaned else "Unknown"


class MetadataGenerator:
    """生成不重复且丰富的艺术家、专辑和歌曲名称"""

    def __init__(self):
        self.used_artists = set()
        self.used_albums = set()

    def generate_artist_name(self, index: int) -> str:
        pattern = random.randint(0, 4)
        if pattern == 0:
            name = f"{random.choice(ARTIST_ADJECTIVES)} {random.choice(ARTIST_NOUNS)}"
        elif pattern == 1:
            name = f"The {random.choice(ARTIST_ADJECTIVES)} {random.choice(ARTIST_NOUNS)}s"
        elif pattern == 2:
            name = f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
        elif pattern == 3:
            name = f"{random.choice(FIRST_NAMES)} & {random.choice(ARTIST_NOUNS)}"
        else:
            name = f"{random.choice(ARTIST_NOUNS)} {random.choice(ALBUM_THEMES)}"

        if name in self.used_artists:
            name = f"{name} {index}"
        self.used_artists.add(name)
        return name

    def generate_album_name(self, artist_name: str, index: int) -> str:
        pattern = random.randint(0, 3)
        if pattern == 0:
            name = f"{random.choice(ARTIST_ADJECTIVES)} {random.choice(ALBUM_THEMES)}"
        elif pattern == 1:
            name = f"{random.choice(ALBUM_THEMES)} {random.choice(ALBUM_CONNECTORS)} {random.choice(TRACK_WORDS_2)}"
        elif pattern == 2:
            name = f"{random.choice(ALBUM_THEMES)} Vol. {index + 1}"
        else:
            name = f"{random.choice(ARTIST_ADJECTIVES)} {random.choice(TRACK_WORDS_2)}"

        key = f"{artist_name}::{name}"
        if key in self.used_albums:
            name = f"{name} #{index + 1}"
        self.used_albums.add(key)
        return name

    def generate_track_title(self) -> str:
        pattern = random.randint(0, 2)
        if pattern == 0:
            return f"{random.choice(TRACK_WORDS_1)} {random.choice(TRACK_WORDS_2)}"
        elif pattern == 1:
            return f"{random.choice(ARTIST_ADJECTIVES)} {random.choice(TRACK_SINGLE_NOUNS)}"
        else:
            return f"{random.choice(TRACK_SINGLE_NOUNS)} of {random.choice(TRACK_WORDS_2)}"


# ----------------- 高性能 ID3v2.3 标签组装器 -----------------

def synchsafe_int(val: int) -> bytes:
    """转换为 ID3v2 使用的 7-bit Synchsafe 整数"""
    return bytes([
        (val >> 21) & 0x7F,
        (val >> 14) & 0x7F,
        (val >> 7) & 0x7F,
        val & 0x7F,
    ])


def make_id3_text_frame(frame_id: bytes, text: str) -> bytes:
    """生成 ID3v2.3 文本帧 (使用 UTF-16LE 带 BOM 编码以兼容所有播放器与系统)"""
    payload = b"\x01\xff\xfe" + text.encode("utf-16-le")
    size = len(payload)
    return frame_id + struct.pack(">I", size) + b"\x00\x00" + payload


def make_id3_apic_frame(image_bytes: bytes, mime_type: str = "image/jpeg") -> bytes:
    """生成 ID3v2.3 内嵌封面 (APIC) 帧"""
    mime_bytes = mime_type.encode("latin1") + b"\x00"
    # Encoding (ISO-8859-1) + MIME + Picture Type (0x03=Front Cover) + Description (\x00) + Image Data
    payload = b"\x00" + mime_bytes + b"\x03\x00" + image_bytes
    size = len(payload)
    return b"APIC" + struct.pack(">I", size) + b"\x00\x00" + payload


def build_id3v23_tag(
    title: str, artist: str, album: str, track_str: str, apic_frame: bytes
) -> bytes:
    """组装完整的 ID3v2.3 头部及标签数据"""
    frames = [
        make_id3_text_frame(b"TIT2", title),
        make_id3_text_frame(b"TPE1", artist),
        make_id3_text_frame(b"TALB", album),
        make_id3_text_frame(b"TRCK", track_str),
        apic_frame,
    ]
    payload = b"".join(frames)
    header = b"ID3\x03\x00\x00" + synchsafe_int(len(payload))
    return header + payload


# ----------------- 音频与文件生成核心 -----------------

def create_raw_mp3_audio(temp_audio_path: str, duration: float, bitrate: str) -> bytes:
    """使用 FFmpeg 快速生成无标签的基础纯音频 MP3 字节流"""
    cmd = [
        "ffmpeg",
        "-y",
        "-f",
        "lavfi",
        "-i",
        "anullsrc=r=44100:cl=stereo",
        "-c:a",
        "libmp3lame",
        "-b:a",
        bitrate,
        "-t",
        str(duration),
        "-write_id3v1",
        "0",
        "-write_id3v2",
        "0",
        temp_audio_path,
    ]
    print(f"[1/4] 正在调用 FFmpeg 生成 {duration}s 静音基础音频流...")
    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        raise RuntimeError(f"FFmpeg 生成音频失败:\n{result.stderr}")

    with open(temp_audio_path, "rb") as f:
        raw_audio_bytes = f.read()

    print(f"[OK] 基础音频流生成成功！大小: {len(raw_audio_bytes) / 1024:.2f} KB\n")
    return raw_audio_bytes


def write_file_worker(task):
    file_path, file_data = task
    with open(file_path, "wb") as f:
        f.write(file_data)


def plan_and_generate_dataset(
    output_dir: str,
    total_files: int,
    target_songs_per_artist: int,
    target_songs_per_album: int,
    cover_image_path: str,
    audio_bytes: bytes,
) -> None:
    """规划并并发生成所有带完整标签及目录结构的测试音乐文件"""
    os.makedirs(output_dir, exist_ok=True)
    print(
        f"[2/4] 正在规划 {total_files} 首歌曲的层级结构 (每位艺术家 ~{target_songs_per_artist} 首, 每张专辑 ~{target_songs_per_album} 首)..."
    )

    with open(cover_image_path, "rb") as f:
        cover_bytes = f.read()
    apic_frame = make_id3_apic_frame(cover_bytes, "image/jpeg")

    meta_gen = MetadataGenerator()
    tasks = []
    created_directories = set()

    songs_created = 0
    artist_count = 0
    album_count = 0

    # 预先规划所有艺术家、专辑和歌曲
    while songs_created < total_files:
        artist_count += 1
        # 艺术家歌曲数量围绕目标值波动 (例如 80% ~ 120%)
        artist_remaining = random.randint(
            max(1, int(target_songs_per_artist * 0.8)),
            int(target_songs_per_artist * 1.2),
        )
        artist_remaining = min(artist_remaining, total_files - songs_created)

        artist_name = meta_gen.generate_artist_name(artist_count)
        clean_artist_name = sanitize_filename(artist_name)

        artist_album_idx = 0
        while artist_remaining > 0 and songs_created < total_files:
            artist_album_idx += 1
            album_count += 1

            # 专辑歌曲数量围绕目标值波动 (例如 15 ~ 25 首)
            album_tracks_target = random.randint(
                max(1, int(target_songs_per_album * 0.75)),
                int(target_songs_per_album * 1.25),
            )
            album_song_count = min(album_tracks_target, artist_remaining, total_files - songs_created)
            artist_remaining -= album_song_count

            album_name = meta_gen.generate_album_name(artist_name, artist_album_idx)
            clean_album_name = sanitize_filename(album_name)

            album_dir = os.path.join(output_dir, clean_artist_name, clean_album_name)
            if album_dir not in created_directories:
                os.makedirs(album_dir, exist_ok=True)
                created_directories.add(album_dir)

            for track_idx in range(1, album_song_count + 1):
                songs_created += 1
                track_title = meta_gen.generate_track_title()
                clean_track_title = sanitize_filename(track_title)
                track_str = f"{track_idx}/{album_song_count}"

                # 组装 ID3v2.3 标签 + 纯音频流
                tag_bytes = build_id3v23_tag(
                    title=track_title,
                    artist=artist_name,
                    album=album_name,
                    track_str=track_str,
                    apic_frame=apic_frame,
                )
                full_file_data = tag_bytes + audio_bytes

                file_name = f"{track_idx:02d}. {clean_track_title}.mp3"
                file_path = os.path.join(album_dir, file_name)

                tasks.append((file_path, full_file_data))

    print(
        f"[3/4] 结构规划完成: 共 {artist_count} 位艺术家, {album_count} 张专辑, {len(tasks)} 首歌曲！"
    )

    cpu_count = os.cpu_count() or 4
    max_workers = min(32, cpu_count * 4)
    print(f"[4/4] 开始多线程快速写入测试文件 ({max_workers} 个并发工作线程)...")

    start_time = time.time()
    last_print = start_time

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for idx, _ in enumerate(executor.map(write_file_worker, tasks), 1):
            now = time.time()
            if idx % 5000 == 0 or idx == total_files or (now - last_print) >= 1.5:
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
    sample_file_size = len(tasks[0][1]) if tasks else 0
    total_size_mb = (sample_file_size * total_files) / (1024 * 1024)

    print(
        f"\n\n[SUCCESS] 完成！成功在 '{output_dir}' 生成了 {total_files} 首测试音乐！"
    )
    print(f"统计信息:")
    print(f"  - 艺术家总数: {artist_count} (平均 ~{total_files/artist_count:.1f} 首/人)")
    print(f"  - 专辑总数:   {album_count} (平均 ~{total_files/album_count:.1f} 首/张)")
    print(f"  - 耗时:       {total_time:.2f} 秒 (平均写入速度: {total_files/total_time:.0f} 首/秒)")
    print(f"  - 总占用空间: ~{total_size_mb:.2f} MB ({total_size_mb/1024:.2f} GB)")


def main():
    parser = argparse.ArgumentParser(
        description="Vynody 10万首测试歌曲生成器 (支持随机艺术家/专辑/内嵌ID3标签与封面)"
    )
    parser.add_argument(
        "--cover", default=DEFAULT_COVER_IMAGE, help="封面图片路径 (默认嵌入到每首歌曲中)"
    )
    parser.add_argument(
        "--output", default=DEFAULT_OUTPUT_DIR, help="输出根目录路径"
    )
    parser.add_argument(
        "--count", type=int, default=DEFAULT_TOTAL_FILES, help="要生成的音乐文件总数 (默认 100,000)"
    )
    parser.add_argument(
        "--songs-per-artist",
        type=int,
        default=DEFAULT_SONGS_PER_ARTIST,
        help="每位艺术家期望的平均歌曲数 (默认 100 左右)",
    )
    parser.add_argument(
        "--songs-per-album",
        type=int,
        default=DEFAULT_SONGS_PER_ALBUM,
        help="每张专辑期望的平均歌曲数 (默认 20 左右)",
    )
    parser.add_argument(
        "--duration", type=float, default=DEFAULT_DURATION, help="单个 MP3 时长（秒）"
    )
    parser.add_argument(
        "--bitrate", default=DEFAULT_BITRATE, help="音频比特率 (默认 96k)"
    )
    args = parser.parse_args()

    if not os.path.isfile(args.cover):
        print(f"[ERROR] 错误: 找不到封面图片文件 '{args.cover}'")
        sys.exit(1)

    temp_audio_path = os.path.join(os.getcwd(), "_temp_base_audio.mp3")

    try:
        raw_audio_bytes = create_raw_mp3_audio(
            temp_audio_path, duration=args.duration, bitrate=args.bitrate
        )
        plan_and_generate_dataset(
            output_dir=args.output,
            total_files=args.count,
            target_songs_per_artist=args.songs_per_artist,
            target_songs_per_album=args.songs_per_album,
            cover_image_path=args.cover,
            audio_bytes=raw_audio_bytes,
        )
    finally:
        if os.path.exists(temp_audio_path):
            try:
                os.remove(temp_audio_path)
            except Exception:
                pass


if __name__ == "__main__":
    main()

