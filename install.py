import shutil
import glob
import sys
import subprocess
import os
from distutils.dir_util import copy_tree


def prRed(skk): print("\033[91m {}\033[00m" .format(skk))


def prGreen(skk): print("\033[92m {}\033[00m" .format(skk))


def prCyan(skk): print("\033[96m {}\033[00m" .format(skk))


def main():
    prCyan('Checking for Python version')
    if not sys.version_info >= (3, 5):
        prRed('ERROR: pgcv installation requires Python3')
        exit()
    else:
        prGreen('- Python3 found')

    prCyan('Creating dist sql file')
    outfilename = os.path.join('dist', 'pgcv--0.1.0.sql')
    with open(outfilename, 'wb') as outfile:
        for filename in sorted(glob.glob(os.path.join('sql', '*.sql'))):
            if filename == outfilename:
                continue
            with open(filename, 'rb') as readfile:
                shutil.copyfileobj(readfile, outfile)
    prGreen('- File successfully created in ' + outfilename)

    prCyan('Installing pgcv requirements')
    subprocess.call([sys.executable, "-m", "pip",
                     "install", "numpy", "scipy", "pandas", "scikit-image", "Pillow"])
    prGreen('- pgcv requirements satisfied')

    prCyan('Looking for the Postgresql share directory')
    extensionsharedir = ''
    try:
        processResult = subprocess.run(
            ["pg_config", "--sharedir"], capture_output=True)
        if processResult.returncode is not 0:
            raise Exception
        sharedir = processResult.stdout.decode('ascii').replace('\n', '')
        extensionsharedir = os.path.join(sharedir, 'extension')
        prGreen('- Extension share directory found at ' + extensionsharedir)
    except:
        prRed("Something wen't wrong getting the share directory")

    prCyan('Copying distribution folder to PostgreSQL share directory')
    copy_tree('dist', extensionsharedir)
    prGreen('- pgcv copied to target directory')

    prCyan('''\n
  pgcv successfully installed.

  Connect to your PostgreSQL database and execute the following commands:

  \tCREATE EXTENSION PLPYTHON3U;
  \tCREATE EXTENSION PGCV;
  ''')


if __name__ == "__main__":
    main()
