#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@ File Name    :   delete_github_repo.py
@ Author       :   Abdalrohman Alnaseer
@ Created Time :   2023/09/23 17:56:00

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


# Get list of repositories
def get_repos():
    url = f"{BASE_URL}/user/repos"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error fetching repositories: {response.text}")
        return []


# Delete a repository
def delete_repo(repo):
    url = f'{BASE_URL}/repos/{repo["owner"]["login"]}/{repo["name"]}'
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f'Deleted repository {repo["full_name"]}')
    else:
        print(f'Error deleting repository {repo["full_name"]}: {response.text}')


# Main function to delete repositories
def delete_repos():
    repos = get_repos()
    for i, repo in enumerate(repos, start=1):
        print(f'{i}. {repo["full_name"]}')
    repo_numbers = input(
        "Enter the numbers of the repositories you want to delete, separated by commas: "
    )
    for repo_number in map(int, repo_numbers.split(",")):
        delete_repo(repos[repo_number - 1])


# Execute the script
if __name__ == "__main__":
    delete_repos()
