#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@ File Name    :   remove_stars_from_github.py
@ Author       :   Abdalrohman Alnaseer
@ Created Time :   2023/09/23 17:55:45

OEM_ROM_Editor
Copyright (C) 2023 Abdalrohman Alnaseer

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
"""

import requests

# GitHub API base URL
BASE_URL = "https://api.github.com"

# Personal access token with the necessary permissions
ACCESS_TOKEN = "YOUR_PERSONAL_ACCESS_TOKEN"

# Headers for authentication
headers = {"Authorization": f"token {ACCESS_TOKEN}", "Accept": "application/vnd.github.v3+json"}


# Get list of starred repositories
def get_starred_repos():
    url = f"{BASE_URL}/user/starred"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error fetching starred repositories: {response.text}")
        return []


# Remove star from a repository
def remove_star(repo):
    url = f'{BASE_URL}/user/starred/{repo["owner"]["login"]}/{repo["name"]}'
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f'Removed star from {repo["full_name"]}')
    else:
        print(f'Error removing star from {repo["full_name"]}: {response.text}')


# Main function to remove stars
def remove_all_stars():
    starred_repos = get_starred_repos()
    for repo in starred_repos:
        remove_star(repo)


# Execute the script
if __name__ == "__main__":
    remove_all_stars()
