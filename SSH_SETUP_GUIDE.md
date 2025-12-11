# SSH Key Setup for GitHub

Follow these steps to set up SSH keys for GitHub authentication, which will allow you to clone the cactus repository using the SSH URL.

## Step 1: Check for Existing SSH Keys

First, check if you already have SSH keys on your system:

```bash
ls -la ~/.ssh
```

Look for files named `id_rsa.pub`, `id_ecdsa.pub`, `id_ed25519.pub`, or similar. If you see these files, you already have SSH keys.

## Step 2: Generate New SSH Key (If Needed)

If you don't have SSH keys, generate a new one:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter to accept the default file location, and optionally enter a passphrase for added security.

## Step 3: Start the SSH Agent

Ensure the SSH agent is running:

```bash
eval "$(ssh-agent -s)"
```

## Step 4: Add Your SSH Key to the Agent

Add your private key to the SSH agent:

```bash
ssh-add ~/.ssh/id_ed25519
```

If you used a different filename or location, adjust the path accordingly.

## Step 5: Copy Your Public Key

Copy your public key to the clipboard:

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

## Step 6: Add Key to GitHub

1. **Sign in to GitHub** at https://github.com

2. **Navigate to SSH and GPG keys**:
   - Click your profile photo in the upper-right corner
   - Select Settings
   - In the left sidebar, click SSH and GPG keys
   - Click New SSH key or Add SSH key

3. **Add your SSH key**:
   - In the "Title" field, add a descriptive label (e.g., "MacBook Pro")
   - Paste your public key into the "Key" field
   - Click Add SSH key

4. **Confirm with your GitHub password** if prompted

## Step 7: Test Your SSH Connection

Test your SSH connection to GitHub:

```bash
ssh -T git@github.com
```

You should see a message like:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

## Step 8: Clone the Cactus Repository

Now you can clone the cactus repository using the SSH URL:

```bash
CACTUS_ROOT_DIR="/path/to/cactus"  # Set this to your desired location
git clone git@github.com:cactus-compute/cactus.git "$CACTUS_ROOT_DIR"
```

## Troubleshooting

### If You Get Permission Denied

1. **Check your SSH keys**: Ensure you've added the correct SSH key to GitHub
2. **Verify the SSH agent**: Make sure your SSH key is added to the agent
3. **Check your email**: Ensure the email used in SSH key generation matches your GitHub email
4. **Use HTTPS as fallback**: If SSH still doesn't work, you can use HTTPS:
   ```bash
   git clone https://github.com/cactus-compute/cactus.git "$CACTUS_ROOT_DIR"
   ```

## Additional Resources

- [GitHub Documentation: Generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [GitHub Documentation: Adding a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
