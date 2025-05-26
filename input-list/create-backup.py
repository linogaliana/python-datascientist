import os
import yaml
import requests
import s3fs
from pathlib import Path
from loguru import logger

# Initialize S3FileSystem
fs = s3fs.S3FileSystem(endpoint_url=os.getenv("AWS_ENDPOINT_URL"))

# Load sources.yaml
with open("./input-list/sources.yaml", "r") as f:
    sources = yaml.safe_load(f)


def download_to_local(raw_url: str, local_path: Path) -> bool:
    try:
        logger.info(f"Downloading from {raw_url} to {local_path}")
        response = requests.get(raw_url, stream=True)
        response.raise_for_status()

        local_path.parent.mkdir(parents=True, exist_ok=True)

        with open(local_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        logger.info(f"Download successful: {local_path}")
        return True
    except Exception as e:
        logger.warning(f"Failed to download {raw_url}: {e}")
        return False


def upload_to_s3(local_path: Path, s3_path: str, fs):
    try:
        logger.info(f"Uploading {local_path} to {s3_path}")
        with fs.open(s3_path, "wb") as s3_file, open(local_path, "rb") as local_file:
            s3_file.write(local_file.read())
        logger.info(f"Upload successful: {s3_path}")
    except Exception as e:
        logger.error(f"Failed to upload to {s3_path}: {e}")


def s3_exists(s3_path: str) -> bool:
    return fs.exists(s3_path)


def process_dataset(sources: dict, key: str, force: bool = False):
    links = sources.get(key)
    if not links:
        logger.warning(f"No dataset found for key: {key}")
        return

    raw_url = links.get("raw")
    backup_url = links.get("backup")

    if not raw_url or not backup_url:
        logger.warning(f"Missing raw or backup URL for key: {key}")
        return

    # Si backup est une liste (cas shapefileUS)
    if isinstance(backup_url, list) and isinstance(raw_url, list):
        for raw, backup in zip(raw_url, backup_url):
            s3_path = backup.replace("https://minio.lab.sspcloud.fr", "s3://")
            process_one_file(raw, s3_path, key, force)
    else:
        s3_path = backup_url.replace("https://minio.lab.sspcloud.fr", "s3://")
        process_one_file(raw_url, s3_path, key, force)


def process_one_file(raw_url: str, s3_path: str, key: str, force: bool):
    if s3_exists(s3_path) and not force:
        logger.info(f"[{key}] Backup already exists at {s3_path}. Skipping.")
        return

    filename = Path(s3_path).name
    local_path = Path("/tmp") / filename

    if download_to_local(raw_url, local_path):
        upload_to_s3(local_path, s3_path, fs)


for key in sources:
    if isinstance(sources[key], dict):
        logger.info(f"Processing {key}")
        try:
            process_dataset(sources, key=key, force=False)
        except Exception as e:
            logger.error(f"❌ Error processing '{key}': {e}")
