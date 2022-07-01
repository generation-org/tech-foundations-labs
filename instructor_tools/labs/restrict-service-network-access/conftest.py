import pytest


def pytest_addoption(parser):
    parser.addoption(
        '--inventory_file',
        action = "store",
        help="add the path for your inveotory file here",
     )

