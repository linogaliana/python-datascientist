/* =====================================================================
   git-sandbox.js — a real git repository that lives entirely in the page.

   Runs isomorphic-git (MIT) against an in-memory filesystem, and renders a
   terminal, a working-directory/staging/repository diagram, and a live commit
   graph. Nothing is sent to a server; nothing is written to disk.

   GENERATED FILE — do not edit. Built from src/ by ./build.sh.
   ===================================================================== */

/* ------------------------------------------------------------------
   git sandbox core: in-memory fs + shell/git command engine + graph model
   No DOM. Works in Node (for tests) and in the browser.
   Requires a global `git` (isomorphic-git UMD).
   ------------------------------------------------------------------ */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.GitSandboxCore = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  /* ---------------------------- memory fs ---------------------------- */

  function createMemFS() {
    var store = new Map();
    var enc = new TextEncoder();
    var dec = new TextDecoder();
    var inode = 1;

    function norm(p) {
      p = String(p).replace(/\\/g, '/');
      if (p.charAt(0) !== '/') p = '/' + p;
      var parts = [];
      p.split('/').forEach(function (seg) {
        if (seg === '' || seg === '.') return;
        if (seg === '..') { parts.pop(); return; }
        parts.push(seg);
      });
      return '/' + parts.join('/');
    }
    function dirname(p) {
      p = norm(p);
      if (p === '/') return '/';
      var i = p.lastIndexOf('/');
      return i <= 0 ? '/' : p.slice(0, i);
    }
    function basename(p) {
      p = norm(p);
      return p.slice(p.lastIndexOf('/') + 1);
    }
    function mkErr(code, path) {
      var msgs = {
        ENOENT: 'no such file or directory',
        EEXIST: 'file already exists',
        ENOTDIR: 'not a directory',
        EISDIR: 'illegal operation on a directory',
        ENOTEMPTY: 'directory not empty',
        EINVAL: 'invalid argument'
      };
      var e = new Error(code + ': ' + (msgs[code] || code) + ", '" + path + "'");
      e.code = code;
      e.path = path;
      e.errno = -1;
      return e;
    }
    function statObj(node) {
      var isDir = node.type === 'dir';
      var isLink = node.type === 'symlink';
      return {
        type: node.type,
        mode: node.mode,
        size: isDir ? 0 : (node.content ? node.content.length : 0),
        ino: node.ino,
        mtimeMs: node.mtimeMs,
        ctimeMs: node.mtimeMs,
        uid: 1, gid: 1, dev: 1,
        isFile: function () { return node.type === 'file'; },
        isDirectory: function () { return isDir; },
        isSymbolicLink: function () { return isLink; }
      };
    }
    function get(p) { return store.get(norm(p)); }
    function requireParentDir(p) {
      var d = dirname(p);
      var pn = store.get(d);
      if (!pn) throw mkErr('ENOENT', p);
      if (pn.type !== 'dir') throw mkErr('ENOTDIR', p);
    }

    store.set('/', { type: 'dir', mode: 16877, mtimeMs: Date.now(), ino: inode++ });

    var promises = {
      readFile: function (p, opts) {
        return Promise.resolve().then(function () {
          var n = get(p);
          if (!n) throw mkErr('ENOENT', p);
          if (n.type === 'dir') throw mkErr('EISDIR', p);
          var encoding = typeof opts === 'string' ? opts : (opts && opts.encoding);
          return encoding ? dec.decode(n.content) : n.content.slice();
        });
      },
      writeFile: function (p, data, opts) {
        return Promise.resolve().then(function () {
          requireParentDir(p);
          var bytes = typeof data === 'string' ? enc.encode(data)
            : (data instanceof Uint8Array ? new Uint8Array(data) : enc.encode(String(data)));
          var mode = (opts && typeof opts === 'object' && opts.mode) || 33188;
          var existing = get(p);
          store.set(norm(p), {
            type: 'file', content: bytes, mode: existing ? existing.mode : mode,
            mtimeMs: Date.now(), ino: existing ? existing.ino : inode++
          });
        });
      },
      unlink: function (p) {
        return Promise.resolve().then(function () {
          var n = get(p);
          if (!n) throw mkErr('ENOENT', p);
          if (n.type === 'dir') throw mkErr('EISDIR', p);
          store.delete(norm(p));
        });
      },
      readdir: function (p) {
        return Promise.resolve().then(function () {
          var d = norm(p);
          var n = store.get(d);
          if (!n) throw mkErr('ENOENT', p);
          if (n.type !== 'dir') throw mkErr('ENOTDIR', p);
          var prefix = d === '/' ? '/' : d + '/';
          var out = [];
          store.forEach(function (_v, k) {
            if (k === d || k.indexOf(prefix) !== 0) return;
            var rest = k.slice(prefix.length);
            if (rest.indexOf('/') === -1 && rest !== '') out.push(rest);
          });
          return out.sort();
        });
      },
      mkdir: function (p, opts) {
        return Promise.resolve().then(function () {
          var d = norm(p);
          if (store.has(d)) {
            if (opts && opts.recursive) return;
            throw mkErr('EEXIST', p);
          }
          if (opts && opts.recursive) {
            var parts = d.split('/').filter(Boolean);
            var cur = '';
            parts.forEach(function (seg) {
              cur += '/' + seg;
              if (!store.has(cur)) store.set(cur, { type: 'dir', mode: 16877, mtimeMs: Date.now(), ino: inode++ });
            });
            return;
          }
          requireParentDir(d);
          store.set(d, { type: 'dir', mode: 16877, mtimeMs: Date.now(), ino: inode++ });
        });
      },
      rmdir: function (p) {
        return Promise.resolve().then(function () {
          var d = norm(p);
          var n = store.get(d);
          if (!n) throw mkErr('ENOENT', p);
          if (n.type !== 'dir') throw mkErr('ENOTDIR', p);
          var prefix = d === '/' ? '/' : d + '/';
          var empty = true;
          store.forEach(function (_v, k) { if (k !== d && k.indexOf(prefix) === 0) empty = false; });
          if (!empty) throw mkErr('ENOTEMPTY', p);
          store.delete(d);
        });
      },
      stat: function (p) {
        return Promise.resolve().then(function () {
          var n = get(p);
          if (!n) throw mkErr('ENOENT', p);
          return statObj(n);
        });
      },
      lstat: function (p) { return promises.stat(p); },
      readlink: function (p) {
        return Promise.resolve().then(function () {
          var n = get(p);
          if (!n || n.type !== 'symlink') throw mkErr('EINVAL', p);
          return n.target;
        });
      },
      symlink: function (target, p) {
        return Promise.resolve().then(function () {
          requireParentDir(p);
          store.set(norm(p), { type: 'symlink', target: target, mode: 41453, mtimeMs: Date.now(), ino: inode++ });
        });
      },
      chmod: function (p, mode) {
        return Promise.resolve().then(function () {
          var n = get(p);
          if (!n) throw mkErr('ENOENT', p);
          n.mode = mode;
        });
      },
      rm: function (p, opts) {
        return Promise.resolve().then(function () {
          var d = norm(p);
          var n = store.get(d);
          if (!n) {
            if (opts && opts.force) return;
            throw mkErr('ENOENT', p);
          }
          if (n.type === 'dir' && opts && opts.recursive) {
            var prefix = d === '/' ? '/' : d + '/';
            var kill = [];
            store.forEach(function (_v, k) { if (k === d || k.indexOf(prefix) === 0) kill.push(k); });
            kill.forEach(function (k) { store.delete(k); });
            return;
          }
          if (n.type === 'dir') throw mkErr('EISDIR', p);
          store.delete(d);
        });
      }
    };

    return {
      promises: promises,
      _store: store,
      _norm: norm,
      _dirname: dirname,
      _basename: basename
    };
  }

  /* --------------------------- tokenizing --------------------------- */

  // Split a command line into tokens, honouring single/double quotes,
  // and pull out redirection targets (> and >>).
  function tokenize(line) {
    var tokens = [];
    var cur = '';
    var has = false;
    var quote = null;
    for (var i = 0; i < line.length; i++) {
      var ch = line[i];
      if (quote) {
        if (ch === quote) { quote = null; }
        else if (ch === '\\' && quote === '"' && i + 1 < line.length) { cur += line[++i]; has = true; }
        else { cur += ch; has = true; }
        continue;
      }
      if (ch === '"' || ch === "'") { quote = ch; has = true; continue; }
      if (ch === ' ' || ch === '\t') {
        if (has) { tokens.push(cur); cur = ''; has = false; }
        continue;
      }
      if (ch === '>' ) {
        if (has) { tokens.push(cur); cur = ''; has = false; }
        if (line[i + 1] === '>') { tokens.push('>>'); i++; } else { tokens.push('>'); }
        continue;
      }
      cur += ch; has = true;
    }
    if (has) tokens.push(cur);
    if (quote) throw new Error('unmatched quote');
    return tokens;
  }

  function splitRedirect(tokens) {
    var out = { args: [], redirect: null, target: null };
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i] === '>' || tokens[i] === '>>') {
        out.redirect = tokens[i];
        out.target = tokens[i + 1] || null;
        i++;
        continue;
      }
      out.args.push(tokens[i]);
    }
    return out;
  }

  /* ------------------------------ engine ---------------------------- */

  function createSandbox(options) {
    options = options || {};
    var gitlib = options.git || (typeof self !== 'undefined' ? self.git : null);
    if (!gitlib) throw new Error('isomorphic-git not found');

    var fs = createMemFS();
    var dir = options.dir || '/project';
    // Path shown to the user in messages and pwd; the real in-memory fs
    // stays rooted at `dir` regardless of what the prompt displays.
    var displayDir = options.displayDir || '~' + dir;
    // Mock remote: a bare repository elsewhere in the same in-memory fs,
    // created by `git remote add origin <url>`. Push/pull/fetch move objects
    // and refs between it and the local repo — nothing leaves the page.
    var remoteGitdir = '/origin';
    var remoteUrl = null;
    var upstreams = {};   // branch name -> true once `push -u` recorded it
    // Merges that actually moved a ref ({ from, into }), via `git merge` or
    // `git pull`. The graph alone cannot distinguish "freshly branched off Y"
    // from "fast-forward merged into Y" — both leave X's tip an ancestor of
    // Y's — so `merged X into Y` conditions need this record.
    var mergesDone = [];
    var author = { name: 'Your Name', email: 'you@example.com' };
    var defaultBranch = options.defaultBranch || 'main';
    var repoReady = false;

    var base = { fs: fs, dir: dir };
    function opts(extra) {
      var o = { fs: fs, dir: dir };
      for (var k in extra) o[k] = extra[k];
      return o;
    }

    function abs(p) {
      if (!p) return dir;
      return p.charAt(0) === '/' ? fs._norm(p) : fs._norm(dir + '/' + p);
    }
    function rel(p) {
      var a = abs(p);
      return a.indexOf(dir + '/') === 0 ? a.slice(dir.length + 1) : a.replace(/^\//, '');
    }

    async function ensureWorkdir() {
      await fs.promises.mkdir(dir, { recursive: true });
    }

    async function isRepo() {
      try { await fs.promises.stat(dir + '/.git'); return true; }
      catch (e) { return false; }
    }

    async function currentBranch() {
      try { return (await gitlib.currentBranch(opts({ fullname: false }))) || null; }
      catch (e) { return null; }
    }

    // list tracked+untracked files in the workdir (excluding .git)
    async function listFiles() {
      var out = [];
      var prefix = dir + '/';
      fs._store.forEach(function (v, k) {
        if (k.indexOf(prefix) !== 0) return;
        if (k.indexOf(dir + '/.git') === 0) return;
        if (v.type !== 'file') return;
        out.push(k.slice(prefix.length));
      });
      return out.sort();
    }

    /* ------------------------------ remote -------------------------- */

    // options builder for commands that read the remote's bare repo
    function ropts(extra) {
      var o = { fs: fs, gitdir: remoteGitdir };
      for (var k in extra) o[k] = extra[k];
      return o;
    }

    async function remoteBranchOid(name) {
      try { return (await fs.promises.readFile(remoteGitdir + '/refs/heads/' + name, 'utf8')).trim(); }
      catch (e) { return null; }
    }

    async function listRemoteBranchNames() {
      try { return (await fs.promises.readdir(remoteGitdir + '/refs/heads')).sort(); }
      catch (e) { return []; }
    }

    // Copy every git object file present under `from` but missing under `to`.
    // Both repos live in the same in-memory fs, so a push/fetch "transfer"
    // is a plain file copy.
    async function copyObjects(fromGitdir, toGitdir) {
      var prefix = fromGitdir + '/objects/';
      var paths = [];
      fs._store.forEach(function (v, k) {
        if (v.type === 'file' && k.indexOf(prefix) === 0) paths.push(k);
      });
      for (var i = 0; i < paths.length; i++) {
        var dest = toGitdir + paths[i].slice(fromGitdir.length);
        try { await fs.promises.stat(dest); continue; } catch (e) { /* missing: copy */ }
        await fs.promises.mkdir(dest.slice(0, dest.lastIndexOf('/')), { recursive: true });
        await fs.promises.writeFile(dest, await fs.promises.readFile(paths[i]));
      }
    }

    // set of commit oids reachable from `oid`, read via the given options builder
    async function reachableFrom(oid, optsFn) {
      var seen = {};
      var queue = [oid];
      while (queue.length) {
        var o = queue.shift();
        if (!o || seen[o]) continue;
        var c;
        try { c = await gitlib.readCommit(optsFn({ oid: o })); } catch (e) { continue; }
        seen[o] = true;
        (c.commit.parent || []).forEach(function (p) { queue.push(p); });
      }
      return seen;
    }

    async function setTrackingRef(branch, oid) {
      await gitlib.writeRef(opts({ ref: 'refs/remotes/origin/' + branch, value: oid, force: true }));
    }

    /* ------------------------- graph model ------------------------- */

    // Shared commit-graph builder. refEntries: [{ name, oid, isHead, remote }].
    // Walks history from the given refs (plus extraSeeds), reading commits
    // with optsFn — opts for the local repo, ropts for the remote.
    async function buildGraph(refEntries, extraSeeds, optsFn) {
      var seeds = refEntries.map(function (e) { return e.oid; })
        .concat(extraSeeds || [])
        .filter(Boolean);

      var seen = new Map();
      var queue = seeds.slice();
      while (queue.length) {
        var oid2 = queue.shift();
        if (!oid2 || seen.has(oid2)) continue;
        var c;
        try { c = await gitlib.readCommit(optsFn({ oid: oid2 })); }
        catch (e) { continue; }
        seen.set(oid2, {
          oid: oid2,
          short: oid2.slice(0, 7),
          message: (c.commit.message || '').split('\n')[0],
          parents: c.commit.parent || [],
          timestamp: c.commit.author.timestamp,
          author: c.commit.author.name,
          refs: []
        });
        (c.commit.parent || []).forEach(function (p) { queue.push(p); });
      }

      // Topological order, children before parents, preferring newer commits.
      // A plain timestamp sort is not enough: commits made in the same second
      // (which happens whenever we seed a repo programmatically) would tie.
      var all = Array.from(seen.values());
      var childCount = {};
      all.forEach(function (c) { childCount[c.oid] = 0; });
      all.forEach(function (c) {
        (c.parents || []).forEach(function (p) {
          if (p in childCount) childCount[p]++;
        });
      });
      var ready = all.filter(function (c) { return childCount[c.oid] === 0; });
      var commits = [];
      var guard = all.length + 1;
      while (ready.length && guard-- > 0) {
        ready.sort(function (a, b) { return b.timestamp - a.timestamp; });
        var next = ready.shift();
        commits.push(next);
        (next.parents || []).forEach(function (p) {
          if (!(p in childCount)) return;
          childCount[p]--;
          if (childCount[p] === 0) ready.push(seen.get(p));
        });
      }
      // safety net: if a cycle ever appeared, fall back to timestamp order
      if (commits.length !== all.length) {
        commits = all.slice().sort(function (a, b) { return b.timestamp - a.timestamp; });
      }

      refEntries.forEach(function (e) {
        var node = seen.get(e.oid);
        if (node) node.refs.push({ name: e.name, isHead: !!e.isHead, remote: !!e.remote });
      });

      // lane assignment: walk newest -> oldest keeping a set of open lanes
      var lanes = [];
      var laneOf = {};
      commits.forEach(function (c2) {
        var lane = lanes.indexOf(c2.oid);
        if (lane === -1) {
          lane = lanes.indexOf(null);
          if (lane === -1) { lane = lanes.length; lanes.push(null); }
        }
        lanes[lane] = null;
        laneOf[c2.oid] = lane;
        c2.lane = lane;
        var ps = c2.parents || [];
        if (ps.length) {
          lanes[lane] = ps[0];
          for (var j = 1; j < ps.length; j++) {
            if (lanes.indexOf(ps[j]) !== -1) continue;
            var free = lanes.indexOf(null);
            if (free === -1) { lanes.push(ps[j]); } else { lanes[free] = ps[j]; }
          }
        }
      });

      return commits;
    }

    async function graphModel() {
      if (!(await isRepo())) return { commits: [], branches: [], head: null, detached: false, merges: [] };

      var branches = await gitlib.listBranches(opts());
      var head = await currentBranch();
      var refs = {};
      var refEntries = [];

      for (var i = 0; i < branches.length; i++) {
        try {
          var oid = await gitlib.resolveRef(opts({ ref: branches[i] }));
          refs[branches[i]] = oid;
          refEntries.push({ name: branches[i], oid: oid, isHead: branches[i] === head });
        } catch (e) { /* unborn branch */ }
      }

      // remote-tracking refs (origin/*) appear as grey pills, like real git log
      if (remoteUrl) {
        var tracked = [];
        try { tracked = await fs.promises.readdir(dir + '/.git/refs/remotes/origin'); } catch (e) {}
        for (var t = 0; t < tracked.length; t++) {
          try {
            var toid = await gitlib.resolveRef(opts({ ref: 'refs/remotes/origin/' + tracked[t] }));
            refEntries.push({ name: 'origin/' + tracked[t], oid: toid, remote: true });
          } catch (e) { /* dangling tracking ref */ }
        }
      }

      // include HEAD in case it is detached
      var headOid = null;
      try { headOid = await gitlib.resolveRef(opts({ ref: 'HEAD' })); }
      catch (e) { /* no commits yet */ }

      var commits = await buildGraph(refEntries, headOid ? [headOid] : [], opts);

      return {
        commits: commits,
        branches: branches.map(function (b) { return { name: b, oid: refs[b] || null, isHead: b === head }; }),
        head: head,
        headOid: headOid,
        detached: head === null && headOid !== null,
        merges: mergesDone.slice()
      };
    }

    // What the mock remote looks like "on GitHub": its own commit graph plus
    // how the learner's current branch compares to it. Null until
    // `git remote add origin <url>` has run.
    async function remoteModel() {
      if (!remoteUrl) return null;
      var names = await listRemoteBranchNames();
      var refEntries = [];
      for (var i = 0; i < names.length; i++) {
        refEntries.push({ name: 'origin/' + names[i], oid: await remoteBranchOid(names[i]), remote: true });
      }
      var commits = await buildGraph(refEntries, [], ropts);

      var branch = await currentBranch();
      var tracked = false, ahead = 0, behind = 0;
      if (branch) {
        var remoteOid = await remoteBranchOid(branch);
        if (remoteOid) {
          tracked = true;
          var localOid = null;
          try { localOid = await gitlib.resolveRef(opts({ ref: branch })); } catch (e) {}
          var localSet = localOid ? await reachableFrom(localOid, opts) : {};
          var remoteSet = await reachableFrom(remoteOid, ropts);
          Object.keys(localSet).forEach(function (o) { if (!remoteSet[o]) ahead++; });
          Object.keys(remoteSet).forEach(function (o) { if (!localSet[o]) behind++; });
        }
      }
      return {
        url: remoteUrl,
        graph: { commits: commits, branches: names, head: null, detached: false },
        branch: branch, tracked: tracked, ahead: ahead, behind: behind
      };
    }

    /* --------------------------- git status ------------------------ */

    // returns { staged:[], modified:[], untracked:[], deleted:[], stagedDeleted:[] }
    // isomorphic-git statusMatrix rows are [filepath, HEAD, WORKDIR, STAGE] where
    //   HEAD:    0 = absent,               1 = present
    //   WORKDIR: 0 = absent,               1 = same as HEAD, 2 = different from HEAD
    //   STAGE:   0 = absent, 1 = same as HEAD, 2 = same as WORKDIR, 3 = different from both
    async function statusModel() {
      var matrix = await gitlib.statusMatrix(opts());
      var res = { staged: [], modified: [], untracked: [], deleted: [], stagedDeleted: [] };
      matrix.forEach(function (row) {
        var file = row[0], head = row[1], workdir = row[2], stage = row[3];

        if (head === 0) {
          // file is not in the last commit
          if (stage === 0) { if (workdir !== 0) res.untracked.push(file); return; }
          res.staged.push({ file: file, kind: 'new file' });
          if (workdir === 0) res.deleted.push(file);       // staged then deleted on disk
          else if (stage === 3) res.modified.push(file);   // staged, then edited again
          return;
        }

        // file was in the last commit
        if (stage === 0) { res.stagedDeleted.push(file); if (workdir !== 0) res.untracked.push(file); return; }
        if (workdir === 0) { res.deleted.push(file); return; }
        if (stage === 1) { if (workdir === 2) res.modified.push(file); return; }
        // stage 2 or 3 => something is staged
        if (workdir === 2 || stage === 3) {
          res.staged.push({ file: file, kind: 'modified' });
          if (stage === 3) res.modified.push(file);        // staged one version, edited again
        }
      });
      return res;
    }

    /* -------------------------- git commands ----------------------- */

    async function gitCommand(args) {
      var sub = args[0];
      var rest = args.slice(1);

      if (!sub) return { out: usageGit(), ok: false };

      if (sub !== 'init' && sub !== 'help' && sub !== 'config' && !(await isRepo())) {
        return { out: 'fatal: not a git repository (or any of the parent directories): .git\nHint: run `git init` first.', ok: false };
      }

      switch (sub) {
        case 'init': {
          if (await isRepo()) return { out: 'Reinitialized existing Git repository in ' + displayDir + '/.git/', ok: true };
          await gitlib.init(opts({ defaultBranch: defaultBranch }));
          repoReady = true;
          return { out: 'Initialized empty Git repository in ' + displayDir + '/.git/', ok: true };
        }

        case 'config': {
          if (rest[0] === 'user.name' && rest[1]) { author.name = rest.slice(1).join(' '); return { out: '', ok: true }; }
          if (rest[0] === 'user.email' && rest[1]) { author.email = rest[1]; return { out: '', ok: true }; }
          if (rest[0] === 'user.name') return { out: author.name, ok: true };
          if (rest[0] === 'user.email') return { out: author.email, ok: true };
          return { out: 'usage: git config user.name "Your Name"', ok: false };
        }

        case 'status': {
          var st = await statusModel();
          var br = await currentBranch();
          var lines = ['On branch ' + (br || 'HEAD (detached)')];
          var anyCommit = true;
          try { await gitlib.resolveRef(opts({ ref: 'HEAD' })); }
          catch (e) { anyCommit = false; }
          if (!anyCommit) lines.push('', 'No commits yet');

          if (st.staged.length || st.stagedDeleted.length) {
            lines.push('', 'Changes to be committed:');
            st.staged.forEach(function (s) { lines.push('  {g}' + s.kind + ':   ' + s.file + '{/}'); });
            st.stagedDeleted.forEach(function (f) { lines.push('  {g}deleted:    ' + f + '{/}'); });
          }
          if (st.modified.length || st.deleted.length) {
            lines.push('', 'Changes not staged for commit:');
            st.modified.forEach(function (f) { lines.push('  {r}modified:   ' + f + '{/}'); });
            st.deleted.forEach(function (f) { lines.push('  {r}deleted:    ' + f + '{/}'); });
          }
          if (st.untracked.length) {
            lines.push('', 'Untracked files:');
            st.untracked.forEach(function (f) { lines.push('  {r}' + f + '{/}'); });
          }
          if (!st.staged.length && !st.stagedDeleted.length && !st.modified.length && !st.deleted.length && !st.untracked.length) {
            lines.push('', 'nothing to commit, working tree clean');
          }
          return { out: lines.join('\n'), ok: true };
        }

        case 'add': {
          if (!rest.length) return { out: "Nothing specified, nothing added.\nhint: try 'git add .' or 'git add <file>'", ok: false };
          var added = 0;
          for (var i = 0; i < rest.length; i++) {
            var spec = rest[i];
            if (spec === '.' || spec === '-A' || spec === '--all' || spec === '*') {
              var m = await gitlib.statusMatrix(opts());
              for (var j = 0; j < m.length; j++) {
                var row = m[j];
                if (row[2] === 0) await gitlib.remove(opts({ filepath: row[0] }));
                else await gitlib.add(opts({ filepath: row[0] }));
                added++;
              }
            } else {
              var f = rel(spec);
              try { await fs.promises.stat(abs(spec)); }
              catch (e) { return { out: "fatal: pathspec '" + spec + "' did not match any files", ok: false }; }
              await gitlib.add(opts({ filepath: f }));
              added++;
            }
          }
          return { out: '', ok: true, silentNote: added + ' path(s) staged' };
        }

        case 'rm': {
          var target = rest.filter(function (a) { return a.charAt(0) !== '-'; })[0];
          if (!target) return { out: 'usage: git rm <file>', ok: false };
          await gitlib.remove(opts({ filepath: rel(target) }));
          try { await fs.promises.unlink(abs(target)); } catch (e) {}
          return { out: "rm '" + rel(target) + "'", ok: true };
        }

        case 'commit': {
          var msg = null;
          for (var k = 0; k < rest.length; k++) {
            if (rest[k] === '-m' || rest[k] === '--message') { msg = rest[k + 1]; break; }
            if (rest[k].indexOf('-m') === 0 && rest[k].length > 2) { msg = rest[k].slice(2); break; }
          }
          if (!msg) return { out: 'Aborting commit due to empty commit message.\nhint: use  git commit -m "your message"', ok: false };
          var st2 = await statusModel();
          if (!st2.staged.length && !st2.stagedDeleted.length) {
            var br2 = await currentBranch();
            var extra = st2.untracked.length || st2.modified.length
              ? '\nUse `git add <file>` to stage changes first.' : '';
            return { out: 'On branch ' + br2 + '\nnothing to commit, working tree clean' + extra, ok: false };
          }
          var sha = await gitlib.commit(opts({ message: msg, author: { name: author.name, email: author.email } }));
          var branch3 = await currentBranch();
          var nFiles = st2.staged.length + st2.stagedDeleted.length;
          return {
            out: '[' + branch3 + ' ' + sha.slice(0, 7) + '] ' + msg + '\n ' + nFiles + ' file' + (nFiles === 1 ? '' : 's') + ' changed',
            ok: true
          };
        }

        case 'log': {
          var oneline = rest.indexOf('--oneline') !== -1;
          var commits;
          try { commits = await gitlib.log(opts({ depth: 50 })); }
          catch (e) { return { out: "fatal: your current branch does not have any commits yet", ok: false }; }
          if (!commits.length) return { out: 'fatal: your current branch does not have any commits yet', ok: false };
          // isomorphic-git's log revisits shared history once per merge parent
          var logSeen = {};
          commits = commits.filter(function (c) {
            if (logSeen[c.oid]) return false;
            logSeen[c.oid] = true;
            return true;
          });
          var g = await graphModel();
          var refsByOid = {};
          g.commits.forEach(function (c) { if (c.refs.length) refsByOid[c.oid] = c.refs; });
          var outLines = [];
          commits.forEach(function (c) {
            var decor = refsByOid[c.oid]
              ? ' {y}(' + refsByOid[c.oid].map(function (r) { return r.isHead ? 'HEAD -> ' + r.name : r.name; }).join(', ') + '){/}'
              : '';
            if (oneline) {
              outLines.push('{y}' + c.oid.slice(0, 7) + '{/}' + decor + ' ' + c.commit.message.split('\n')[0]);
            } else {
              outLines.push('{y}commit ' + c.oid + '{/}' + decor);
              outLines.push('Author: ' + c.commit.author.name + ' <' + c.commit.author.email + '>');
              outLines.push('');
              outLines.push('    ' + c.commit.message.split('\n')[0]);
              outLines.push('');
            }
          });
          return { out: outLines.join('\n'), ok: true };
        }

        case 'branch': {
          var del = rest.indexOf('-d') !== -1 || rest.indexOf('-D') !== -1;
          var names = rest.filter(function (a) { return a.charAt(0) !== '-'; });
          var all = await gitlib.listBranches(opts());
          var cur = await currentBranch();
          if (del) {
            if (!names.length) return { out: 'fatal: branch name required', ok: false };
            if (names[0] === cur) return { out: "error: cannot delete branch '" + names[0] + "' checked out at '" + displayDir + "'", ok: false };
            if (all.indexOf(names[0]) === -1) return { out: "error: branch '" + names[0] + "' not found.", ok: false };
            await gitlib.deleteBranch(opts({ ref: names[0] }));
            return { out: "Deleted branch " + names[0], ok: true };
          }
          if (!names.length) {
            if (!all.length) return { out: '', ok: true };
            return { out: all.map(function (b) { return b === cur ? '{g}* ' + b + '{/}' : '  ' + b; }).join('\n'), ok: true };
          }
          if (all.indexOf(names[0]) !== -1) return { out: "fatal: a branch named '" + names[0] + "' already exists", ok: false };
          try { await gitlib.branch(opts({ ref: names[0] })); }
          catch (e) { return { out: 'fatal: ' + e.message, ok: false }; }
          return { out: '', ok: true, silentNote: 'created branch ' + names[0] };
        }

        case 'switch':
        case 'checkout': {
          var create = rest.indexOf('-b') !== -1 || rest.indexOf('-c') !== -1;
          var names2 = rest.filter(function (a) { return a.charAt(0) !== '-'; });
          if (!names2.length) return { out: 'fatal: missing branch name', ok: false };
          var name = names2[0];
          var all2 = await gitlib.listBranches(opts());
          if (create) {
            if (all2.indexOf(name) !== -1) return { out: "fatal: a branch named '" + name + "' already exists", ok: false };
            await gitlib.branch(opts({ ref: name, checkout: true }));
            return { out: "Switched to a new branch '" + name + "'", ok: true };
          }
          if (all2.indexOf(name) === -1) {
            return { out: "error: pathspec '" + name + "' did not match any file(s) known to git\nhint: use `git checkout -b " + name + "` to create it", ok: false };
          }
          await gitlib.checkout(opts({ ref: name }));
          return { out: "Switched to branch '" + name + "'", ok: true };
        }

        case 'merge': {
          var theirs = rest.filter(function (a) { return a.charAt(0) !== '-'; })[0];
          if (!theirs) return { out: 'usage: git merge <branch>', ok: false };
          var ours = await currentBranch();
          var known = await gitlib.listBranches(opts());
          if (known.indexOf(theirs) === -1) return { out: "merge: " + theirs + " - not something we can merge", ok: false };
          if (theirs === ours) return { out: 'Already up to date.', ok: true };
          var result;
          try {
            result = await gitlib.merge(opts({
              ours: ours, theirs: theirs,
              author: { name: author.name, email: author.email },
              message: "Merge branch '" + theirs + "' into " + ours
            }));
          } catch (e) {
            if (e.code === 'MergeNotSupportedError' || e.code === 'MergeConflictError') {
              return {
                out: 'CONFLICT: both branches changed the same file.\n' +
                     'Automatic merge failed. In this sandbox, conflicts are not resolvable —\n' +
                     'try `reset` and take the guided path instead.',
                ok: false
              };
            }
            return { out: 'fatal: ' + e.message, ok: false };
          }
          // bring the working directory in line with the new ref
          await gitlib.checkout(opts({ ref: ours, force: true }));
          if (result.alreadyMerged) return { out: 'Already up to date.', ok: true };
          mergesDone.push({ from: theirs, into: ours });
          if (result.fastForward) return { out: 'Updating ' + (result.oid || '').slice(0, 7) + '\nFast-forward', ok: true };
          return { out: "Merge made by the 'recursive' strategy.", ok: true };
        }

        case 'remote': {
          if (rest[0] === 'add') {
            if (rest[1] !== 'origin' || !rest[2]) return { out: 'usage: git remote add origin <url>', ok: false };
            if (remoteUrl) return { out: 'error: remote origin already exists.', ok: false };
            await gitlib.init({ fs: fs, gitdir: remoteGitdir, bare: true, defaultBranch: defaultBranch });
            remoteUrl = rest[2];
            return { out: '', ok: true };
          }
          if (!rest.length) return { out: remoteUrl ? 'origin' : '', ok: true };
          if (rest[0] === '-v') {
            if (!remoteUrl) return { out: '', ok: true };
            return { out: 'origin\t' + remoteUrl + ' (fetch)\norigin\t' + remoteUrl + ' (push)', ok: true };
          }
          return { out: 'usage: git remote [-v] | git remote add origin <url>', ok: false };
        }

        case 'push': {
          if (!remoteUrl) return { out: 'fatal: No configured push destination.\nAdd a remote first: git remote add origin <url>', ok: false };
          var setUp = rest.indexOf('-u') !== -1 || rest.indexOf('--set-upstream') !== -1;
          var words = rest.filter(function (a) { return a.charAt(0) !== '-'; });
          if (words[0] && words[0] !== 'origin') return { out: "fatal: '" + words[0] + "' does not appear to be a git repository", ok: false };
          var pbr = words[1] || (await currentBranch());
          if (!pbr) return { out: 'fatal: you are not currently on a branch.', ok: false };
          var locals = await gitlib.listBranches(opts());
          if (locals.indexOf(pbr) === -1) return { out: 'error: src refspec ' + pbr + ' does not match any', ok: false };
          if (!words[1] && !upstreams[pbr]) {
            return {
              out: 'fatal: The current branch ' + pbr + ' has no upstream branch.\n' +
                   'To push the current branch and set the remote as upstream, use\n\n' +
                   '    git push -u origin ' + pbr,
              ok: false
            };
          }
          var localOid = await gitlib.resolveRef(opts({ ref: pbr }));
          var remoteOid = await remoteBranchOid(pbr);
          if (setUp) upstreams[pbr] = true;
          if (remoteOid === localOid) return { out: 'Everything up-to-date', ok: true };
          if (remoteOid) {
            // only fast-forward pushes are allowed, like a real remote
            var pushedSet = await reachableFrom(localOid, opts);
            if (!pushedSet[remoteOid]) {
              return {
                out: 'To ' + remoteUrl + '\n' +
                     ' {r}! [rejected]{/}        ' + pbr + ' -> ' + pbr + ' (fetch first)\n' +
                     'hint: Updates were rejected because the remote contains work that you do\n' +
                     'hint: not have locally. Pull the remote changes ({y}git pull{/}) before pushing again.',
                ok: false
              };
            }
          }
          await copyObjects(dir + '/.git', remoteGitdir);
          await fs.promises.mkdir(remoteGitdir + '/refs/heads', { recursive: true });
          await fs.promises.writeFile(remoteGitdir + '/refs/heads/' + pbr, localOid + '\n');
          await setTrackingRef(pbr, localOid);
          var pushOut = ['To ' + remoteUrl];
          pushOut.push(remoteOid
            ? '   ' + remoteOid.slice(0, 7) + '..' + localOid.slice(0, 7) + '  ' + pbr + ' -> ' + pbr
            : ' * [new branch]      ' + pbr + ' -> ' + pbr);
          if (setUp) pushOut.push("branch '" + pbr + "' set up to track 'origin/" + pbr + "'.");
          return { out: pushOut.join('\n'), ok: true };
        }

        case 'fetch': {
          if (!remoteUrl) return { out: "fatal: 'origin' does not appear to be a git repository", ok: false };
          var rnames = await listRemoteBranchNames();
          await copyObjects(remoteGitdir, dir + '/.git');
          var updated = [];
          for (var fi = 0; fi < rnames.length; fi++) {
            var rOid = await remoteBranchOid(rnames[fi]);
            var cur = null;
            try { cur = await gitlib.resolveRef(opts({ ref: 'refs/remotes/origin/' + rnames[fi] })); } catch (e) {}
            if (cur === rOid) continue;
            await setTrackingRef(rnames[fi], rOid);
            updated.push(cur
              ? '   ' + cur.slice(0, 7) + '..' + rOid.slice(0, 7) + '  ' + rnames[fi] + '       -> origin/' + rnames[fi]
              : ' * [new branch]      ' + rnames[fi] + '       -> origin/' + rnames[fi]);
          }
          if (!updated.length) return { out: '', ok: true };
          return { out: ['From ' + remoteUrl].concat(updated).join('\n'), ok: true };
        }

        case 'pull': {
          if (!remoteUrl) return { out: "fatal: 'origin' does not appear to be a git repository", ok: false };
          var lbr = await currentBranch();
          if (!lbr) return { out: 'fatal: you are not currently on a branch.', ok: false };
          var fetched = await gitCommand(['fetch']);
          var theirOid = await remoteBranchOid(lbr);
          if (!theirOid) return { out: "fatal: origin has no branch named '" + lbr + "' to pull from.", ok: false };
          var oursOid = await gitlib.resolveRef(opts({ ref: lbr }));
          var prefix2 = fetched.out ? fetched.out + '\n' : '';
          if (theirOid === oursOid) return { out: prefix2 + 'Already up to date.', ok: true };
          var pres;
          try {
            pres = await gitlib.merge(opts({
              ours: lbr, theirs: 'refs/remotes/origin/' + lbr,
              author: { name: author.name, email: author.email },
              message: "Merge branch '" + lbr + "' of " + remoteUrl
            }));
          } catch (e) {
            if (e.code === 'MergeNotSupportedError' || e.code === 'MergeConflictError') {
              return {
                out: prefix2 + 'CONFLICT: the remote changed the same lines you did.\n' +
                     'Automatic merge failed. In this sandbox, conflicts are not resolvable yet —\n' +
                     'try `reset` and take the guided path instead.',
                ok: false
              };
            }
            return { out: prefix2 + 'fatal: ' + e.message, ok: false };
          }
          await gitlib.checkout(opts({ ref: lbr, force: true }));
          if (pres.alreadyMerged) return { out: prefix2 + 'Already up to date.', ok: true };
          mergesDone.push({ from: 'origin/' + lbr, into: lbr });
          if (pres.fastForward) return { out: prefix2 + 'Updating ' + oursOid.slice(0, 7) + '..' + theirOid.slice(0, 7) + '\nFast-forward', ok: true };
          return { out: prefix2 + "Merge made by the 'recursive' strategy.", ok: true };
        }

        case 'diff': {
          var st3 = await statusModel();
          if (!st3.modified.length && !st3.untracked.length) return { out: '', ok: true };
          var chunks = [];
          for (var d = 0; d < st3.modified.length; d++) {
            var file = st3.modified[d];
            var headOid = await gitlib.resolveRef(opts({ ref: 'HEAD' }));
            var blob = await gitlib.readBlob(opts({ oid: headOid, filepath: file }));
            var oldTxt = new TextDecoder().decode(blob.blob);
            var newTxt = await fs.promises.readFile(dir + '/' + file, 'utf8');
            chunks.push('{w}diff --git a/' + file + ' b/' + file + '{/}');
            chunks.push(simpleDiff(oldTxt, newTxt));
          }
          return { out: chunks.join('\n'), ok: true };
        }

        case 'help':
          return { out: usageGit(), ok: true };

        default:
          return { out: "git: '" + sub + "' is not supported in this sandbox.\n" + usageGit(), ok: false };
      }
    }

    // Line-by-line diff as data: [{ t: ' '|'+'|'-', text, a, b }] where a/b
    // are 1-based line numbers in the old/new file (absent on the other side).
    function diffLines(oldTxt, newTxt) {
      var a = oldTxt.split('\n'), b = newTxt.split('\n');
      var out = [];
      var i = 0, j = 0;
      while (i < a.length || j < b.length) {
        if (i < a.length && j < b.length && a[i] === b[j]) { out.push({ t: ' ', text: a[i], a: i + 1, b: j + 1 }); i++; j++; }
        else if (j < b.length && (i >= a.length || a.indexOf(b[j], i) === -1)) { out.push({ t: '+', text: b[j], b: j + 1 }); j++; }
        else if (i < a.length) { out.push({ t: '-', text: a[i], a: i + 1 }); i++; }
        else break;
      }
      return out;
    }

    function simpleDiff(oldTxt, newTxt) {
      return diffLines(oldTxt, newTxt).map(function (l) {
        if (l.t === '+') return '{g}+' + l.text + '{/}';
        if (l.t === '-') return '{r}-' + l.text + '{/}';
        return ' ' + l.text;
      }).join('\n');
    }

    // Working directory vs the last commit, structured for rendering:
    // { files: [{ file, kind: 'new'|'modified'|'deleted', lines: [...] }] }
    // or null when there is no repository yet.
    async function diffModel() {
      if (!(await isRepo())) return null;
      var headOid = null;
      try { headOid = await gitlib.resolveRef(opts({ ref: 'HEAD' })); } catch (e) {}
      var matrix = await gitlib.statusMatrix(opts());
      var files = [];
      for (var r = 0; r < matrix.length; r++) {
        var file = matrix[r][0], head = matrix[r][1], workdir = matrix[r][2];
        if (head === workdir) continue;                       // unchanged or absent
        var kind = head === 0 ? 'new' : (workdir === 0 ? 'deleted' : 'modified');
        var oldTxt = '', newTxt = '';
        if (head === 1 && headOid) {
          var blob = await gitlib.readBlob(opts({ oid: headOid, filepath: file }));
          oldTxt = new TextDecoder().decode(blob.blob);
        }
        if (workdir !== 0) newTxt = await fs.promises.readFile(dir + '/' + file, 'utf8');
        // Strip one trailing newline per side so the panel never shows a
        // phantom blank last line.
        oldTxt = oldTxt.replace(/\n$/, '');
        newTxt = newTxt.replace(/\n$/, '');
        var lines;
        if (kind === 'new') lines = newTxt.split('\n').map(function (t, k) { return { t: '+', text: t, b: k + 1 }; });
        else if (kind === 'deleted') lines = oldTxt.split('\n').map(function (t, k) { return { t: '-', text: t, a: k + 1 }; });
        else lines = diffLines(oldTxt, newTxt);
        files.push({ file: file, kind: kind, lines: lines });
      }
      return { files: files };
    }

    function usageGit() {
      return [
        'Supported git commands in this sandbox:',
        '  git init                      git status',
        '  git add <file> | .            git commit -m "message"',
        '  git log [--oneline]           git diff',
        '  git branch [name] [-d name]   git checkout [-b] <branch>',
        '  git switch [-c] <branch>      git merge <branch>',
        '  git remote add origin <url>   git push [-u origin <branch>]',
        '  git fetch                     git pull',
        '  git config user.name "..."'
      ].join('\n');
    }

    /* ------------------------- shell commands ---------------------- */

    async function shellCommand(cmd, args, redirect, target) {
      switch (cmd) {
        case 'ls': {
          var showAll = args.indexOf('-a') !== -1 || args.indexOf('-la') !== -1 || args.indexOf('-al') !== -1;
          var entries = await fs.promises.readdir(dir);
          if (!showAll) entries = entries.filter(function (e) { return e.charAt(0) !== '.'; });
          if (!entries.length) return { out: '', ok: true };
          var marked = [];
          for (var i = 0; i < entries.length; i++) {
            var s = await fs.promises.stat(dir + '/' + entries[i]);
            marked.push(s.isDirectory() ? '{b}' + entries[i] + '/{/}' : entries[i]);
          }
          return { out: marked.join('  '), ok: true };
        }
        case 'cat': {
          if (!args.length) return { out: 'usage: cat <file>', ok: false };
          try {
            var txt = await fs.promises.readFile(abs(args[0]), 'utf8');
            return { out: txt.replace(/\n$/, ''), ok: true };
          } catch (e) {
            return { out: 'cat: ' + args[0] + ': No such file or directory', ok: false };
          }
        }
        case 'echo': {
          var text = args.join(' ');
          if (redirect && target) {
            var p = abs(target);
            var prev = '';
            if (redirect === '>>') { try { prev = await fs.promises.readFile(p, 'utf8'); } catch (e) {} }
            await fs.promises.writeFile(p, prev + text + '\n');
            return { out: '', ok: true, silentNote: 'wrote ' + rel(target) };
          }
          return { out: text, ok: true };
        }
        case 'touch': {
          if (!args.length) return { out: 'usage: touch <file>', ok: false };
          for (var t = 0; t < args.length; t++) {
            var pt = abs(args[t]);
            try { await fs.promises.stat(pt); }
            catch (e) { await fs.promises.writeFile(pt, ''); }
          }
          return { out: '', ok: true, silentNote: 'touched ' + args.join(' ') };
        }
        case 'rm': {
          var files = args.filter(function (a) { return a.charAt(0) !== '-'; });
          if (!files.length) return { out: 'usage: rm <file>', ok: false };
          for (var r = 0; r < files.length; r++) {
            try { await fs.promises.unlink(abs(files[r])); }
            catch (e) { return { out: 'rm: ' + files[r] + ': No such file or directory', ok: false }; }
          }
          return { out: '', ok: true };
        }
        case 'mkdir': {
          if (!args.length) return { out: 'usage: mkdir <dir>', ok: false };
          await fs.promises.mkdir(abs(args[args.length - 1]), { recursive: true });
          return { out: '', ok: true };
        }
        case 'pwd':
          return { out: displayDir, ok: true };
        // Authoring helper for seeds: move the current branch back n commits
        // (first parent), so a previously-pushed commit exists only on the
        // remote — the "colleague pushed while you were away" setup.
        case 'rewind': {
          var back = parseInt(args[0] || '1', 10);
          if (!(back > 0)) return { out: 'usage: rewind <n>', ok: false };
          var rbr = await currentBranch();
          if (!rbr) return { out: 'rewind: not on a branch', ok: false };
          var roid = await gitlib.resolveRef(opts({ ref: rbr }));
          for (var rw = 0; rw < back; rw++) {
            var rc = await gitlib.readCommit(opts({ oid: roid }));
            var rp = rc.commit.parent || [];
            if (!rp.length) return { out: 'rewind: not enough history to rewind ' + back, ok: false };
            roid = rp[0];
          }
          await gitlib.writeRef(opts({ ref: 'refs/heads/' + rbr, value: roid, force: true }));
          // keep the tracking ref in step so the learner discovers the newer
          // remote commits with `git fetch`, not automatically
          try {
            await gitlib.resolveRef(opts({ ref: 'refs/remotes/origin/' + rbr }));
            await setTrackingRef(rbr, roid);
          } catch (e) { /* no tracking ref yet */ }
          await gitlib.checkout(opts({ ref: rbr, force: true }));
          return { out: '', ok: true, silentNote: 'rewound ' + rbr + ' by ' + back };
        }
        case 'whoami':
          return { out: author.name + ' <' + author.email + '>', ok: true };
        default:
          return null;
      }
    }

    /* ---------------------------- dispatch -------------------------- */

    async function run(line) {
      line = String(line || '').trim();
      if (!line) return { out: '', ok: true, kind: 'empty' };

      var tokens;
      try { tokens = tokenize(line); }
      catch (e) { return { out: 'sh: ' + e.message, ok: false, kind: 'error' }; }

      var parsed = splitRedirect(tokens);
      var args = parsed.args;
      var cmd = args[0];

      await ensureWorkdir();

      try {
        if (cmd === 'git') {
          var r = await gitCommand(args.slice(1));
          r.kind = 'git';
          return r;
        }
        var sh = await shellCommand(cmd, args.slice(1), parsed.redirect, parsed.target);
        if (sh) { sh.kind = 'shell'; return sh; }
        return {
          out: cmd + ': command not found\nType `help` to see what this sandbox supports.',
          ok: false, kind: 'error'
        };
      } catch (e) {
        return { out: 'error: ' + (e && e.message ? e.message : String(e)), ok: false, kind: 'error' };
      }
    }

    /* ------------------------- undo snapshots ------------------------ */

    // Everything a command can change lives in the in-memory store (working
    // files, .git, the bare mock remote) plus a few closure variables, so a
    // full state snapshot is a clone of both. Repos here are a few KB, so
    // cloning per command is cheap.
    function cloneStore(src) {
      var out = new Map();
      src.forEach(function (node, key) {
        var copy = {};
        for (var k in node) copy[k] = node[k];
        if (node.content instanceof Uint8Array) copy.content = new Uint8Array(node.content);
        out.set(key, copy);
      });
      return out;
    }

    function snapshot() {
      return {
        store: cloneStore(fs._store),
        remoteUrl: remoteUrl,
        upstreams: JSON.parse(JSON.stringify(upstreams)),
        merges: mergesDone.map(function (m) { return { from: m.from, into: m.into }; }),
        author: { name: author.name, email: author.email },
        repoReady: repoReady
      };
    }

    function restore(snap) {
      var cloned = cloneStore(snap.store);
      // mutate the existing store so every closure holding `fs` stays valid
      fs._store.clear();
      cloned.forEach(function (v, k) { fs._store.set(k, v); });
      remoteUrl = snap.remoteUrl;
      upstreams = JSON.parse(JSON.stringify(snap.upstreams));
      mergesDone = snap.merges.map(function (m) { return { from: m.from, into: m.into }; });
      author = { name: snap.author.name, email: snap.author.email };
      repoReady = snap.repoReady;
    }

    // Did anything meaningful change since the snapshot? Compares content,
    // not mtimes, so rewriting a file with identical bytes does not count.
    function changedSince(snap) {
      if (remoteUrl !== snap.remoteUrl) return true;
      if (mergesDone.length !== snap.merges.length) return true;
      if (JSON.stringify(upstreams) !== JSON.stringify(snap.upstreams)) return true;
      if (author.name !== snap.author.name || author.email !== snap.author.email) return true;
      if (fs._store.size !== snap.store.size) return true;
      var diff = false;
      fs._store.forEach(function (node, key) {
        if (diff) return;
        var old = snap.store.get(key);
        if (!old || old.type !== node.type) { diff = true; return; }
        var a = node.content, b = old.content;
        if (!a !== !b) { diff = true; return; }
        if (a && b) {
          if (a.length !== b.length) { diff = true; return; }
          for (var i = 0; i < a.length; i++) {
            if (a[i] !== b[i]) { diff = true; return; }
          }
        }
      });
      return diff;
    }

    async function reset(seed) {
      fs = createMemFS();
      base.fs = fs;
      repoReady = false;
      remoteUrl = null;
      upstreams = {};
      mergesDone = [];
      author = { name: 'Your Name', email: 'you@example.com' };
      await ensureWorkdir();
      if (seed) await seed(api);
    }

    var api = {
      run: run,
      reset: reset,
      snapshot: snapshot,
      restore: restore,
      changedSince: changedSince,
      graphModel: graphModel,
      statusModel: statusModel,
      diffModel: diffModel,
      remoteModel: remoteModel,
      isRepo: isRepo,
      currentBranch: currentBranch,
      listFiles: listFiles,
      readFile: function (p) { return fs.promises.readFile(abs(p), 'utf8'); },
      writeFile: function (p, c) { return ensureWorkdir().then(function () { return fs.promises.writeFile(abs(p), c); }); },
      get fs() { return fs; },
      get dir() { return dir; },
      git: gitlib
    };
    return api;
  }

  return {
    createSandbox: createSandbox,
    createMemFS: createMemFS,
    tokenize: tokenize,
    splitRedirect: splitRedirect
  };
});


/* ------------------------------------------------------------------
   The `when:` mini-language.

   Lesson authors describe what a learner must achieve as a condition on
   repository state rather than as JavaScript:

     when: repo
     when: commits >= 2
     when: commits on report >= 3
     when: branch report and on main
     when: merged report into main
     when: merge commit
     when: file report.qmd contains "Q3"
     when: ran /git\s+status/
     when: not clean

   compileWhen(src) returns a predicate (ctx) => boolean, or throws an Error
   with an author-facing message. Compilation happens once at mount time so
   mistakes surface immediately rather than on the learner's tenth command.
   ------------------------------------------------------------------ */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.GitSandboxWhen = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  var KEYWORDS = ['and', 'or', 'not'];

  /* ------------------------------ tokenizer ------------------------------ */

  function tokenize(src) {
    var tokens = [];
    var i = 0;
    var n = src.length;
    while (i < n) {
      var c = src[i];
      if (/\s/.test(c)) { i++; continue; }
      if (c === '(' || c === ')') { tokens.push({ t: c, v: c, at: i }); i++; continue; }
      if (c === '"' || c === "'") {
        var q = c, buf = '', start = i;
        i++;
        while (i < n && src[i] !== q) {
          if (src[i] === '\\' && i + 1 < n) { buf += src[i + 1]; i += 2; }
          else { buf += src[i]; i++; }
        }
        if (i >= n) throw new Error('unterminated string starting at character ' + (start + 1));
        i++;
        tokens.push({ t: 'str', v: buf, at: start });
        continue;
      }
      if (c === '/') {
        var rstart = i, rbuf = '';
        i++;
        while (i < n && src[i] !== '/') {
          if (src[i] === '\\' && i + 1 < n) { rbuf += src[i] + src[i + 1]; i += 2; }
          else { rbuf += src[i]; i++; }
        }
        if (i >= n) throw new Error('unterminated /regex/ starting at character ' + (rstart + 1));
        i++;
        var flags = '';
        while (i < n && /[a-z]/.test(src[i])) { flags += src[i]; i++; }
        tokens.push({ t: 'regex', v: rbuf, flags: flags, at: rstart });
        continue;
      }
      var opMatch = /^(>=|<=|==|=|>|<)/.exec(src.slice(i));
      if (opMatch) { tokens.push({ t: 'op', v: opMatch[1], at: i }); i += opMatch[1].length; continue; }
      var wordMatch = /^[^\s()]+/.exec(src.slice(i));
      if (!wordMatch) throw new Error('unexpected character ' + JSON.stringify(c));
      var w = wordMatch[0];
      if (/^\d+$/.test(w)) tokens.push({ t: 'num', v: parseInt(w, 10), at: i });
      else if (KEYWORDS.indexOf(w) !== -1) tokens.push({ t: w, v: w, at: i });
      else tokens.push({ t: 'word', v: w, at: i });
      i += w.length;
    }
    return tokens;
  }

  /* ------------------------------ predicates ----------------------------- */

  function ui() {
    return (typeof self !== 'undefined' && self.GitSandboxUI) || null;
  }
  function branchOid(ctx, name) {
    var b = (ctx.graph.branches || []).filter(function (x) { return x.name === name; })[0];
    return b ? b.oid : null;
  }
  function reaches(ctx, from, target) {
    if (!from || !target) return false;
    if (from === target) return true;
    var byOid = {};
    ctx.graph.commits.forEach(function (c) { byOid[c.oid] = c; });
    var stack = [from], seen = {};
    while (stack.length) {
      var oid = stack.pop();
      if (oid === target) return true;
      if (seen[oid]) continue;
      seen[oid] = true;
      var c = byOid[oid];
      if (c) (c.parents || []).forEach(function (p) { stack.push(p); });
    }
    return false;
  }
  function commitCount(ctx, name) {
    if (!name) return ctx.graph.commits.length;
    var tip = branchOid(ctx, name);
    if (!tip) return 0;
    var byOid = {};
    ctx.graph.commits.forEach(function (c) { byOid[c.oid] = c; });
    var stack = [tip], seen = {}, count = 0;
    while (stack.length) {
      var oid = stack.pop();
      if (seen[oid]) continue;
      seen[oid] = true;
      count++;
      var c = byOid[oid];
      if (c) (c.parents || []).forEach(function (p) { stack.push(p); });
    }
    return count;
  }
  function compare(op, left, right) {
    switch (op) {
      case '>=': return left >= right;
      case '>': return left > right;
      case '<=': return left <= right;
      case '<': return left < right;
      case '==':
      case '=': return left === right;
    }
    return false;
  }

  /* -------------------------------- parser ------------------------------- */

  function parse(src) {
    var tokens = tokenize(src);
    var pos = 0;

    function peek(k) { return tokens[pos + (k || 0)]; }
    function next() { return tokens[pos++]; }
    function describe(tok) {
      if (!tok) return 'end of expression';
      return JSON.stringify(String(tok.v));
    }
    function expectWord(what) {
      var tok = peek();
      if (!tok || (tok.t !== 'word' && tok.t !== 'str' && tok.t !== 'num')) {
        throw new Error('expected ' + what + ' but found ' + describe(tok));
      }
      return String(next().v);
    }

    function parseOr() {
      var left = parseAnd();
      while (peek() && peek().t === 'or') {
        next();
        var right = parseAnd();
        left = (function (a, b) {
          return function (ctx) { return a(ctx) || b(ctx); };
        })(left, right);
      }
      return left;
    }

    function parseAnd() {
      var left = parseNot();
      while (peek() && peek().t === 'and') {
        next();
        var right = parseNot();
        left = (function (a, b) {
          return function (ctx) { return a(ctx) && b(ctx); };
        })(left, right);
      }
      return left;
    }

    function parseNot() {
      if (peek() && peek().t === 'not') {
        next();
        var inner = parseNot();
        return function (ctx) { return !inner(ctx); };
      }
      if (peek() && peek().t === '(') {
        next();
        var expr = parseOr();
        if (!peek() || peek().t !== ')') {
          throw new Error('missing closing parenthesis');
        }
        next();
        return expr;
      }
      return parsePredicate();
    }

    function parsePredicate() {
      var tok = peek();
      if (!tok) throw new Error('expression ended early; expected a condition');
      if (tok.t !== 'word') {
        throw new Error('expected a condition but found ' + describe(tok));
      }
      var word = String(next().v);

      switch (word) {
        case 'repo':
          return function (ctx) { return !!ctx.isRepo; };

        case 'clean':
          return function (ctx) {
            var s = ctx.status;
            return ctx.isRepo && s.staged.length === 0 && s.modified.length === 0 &&
                   s.untracked.length === 0 && s.deleted.length === 0 &&
                   s.stagedDeleted.length === 0;
          };

        case 'staged':
          return function (ctx) {
            return ctx.status.staged.length > 0 || ctx.status.stagedDeleted.length > 0;
          };

        case 'merge': {
          var m = peek();
          if (!m || String(m.v) !== 'commit') {
            throw new Error('expected "merge commit" but found "merge ' +
              (m ? String(m.v) : '') + '"');
          }
          next();
          return function (ctx) {
            return ctx.graph.commits.some(function (c) { return (c.parents || []).length > 1; });
          };
        }

        case 'commits': {
          var branch = null;
          if (peek() && peek().t === 'word' && String(peek().v) === 'on') {
            next();
            branch = expectWord('a branch name after "commits on"');
          }
          var op = '>=';
          if (peek() && peek().t === 'op') op = String(next().v);
          var numTok = peek();
          if (!numTok || numTok.t !== 'num') {
            throw new Error('expected a number after "commits' +
              (branch ? ' on ' + branch : '') + (op !== '>=' ? ' ' + op : '') +
              '" but found ' + describe(numTok));
          }
          next();
          var want = numTok.v;
          return function (ctx) { return compare(op, commitCount(ctx, branch), want); };
        }

        case 'branch': {
          var bname = expectWord('a branch name after "branch"');
          return function (ctx) {
            return (ctx.graph.branches || []).some(function (b) { return b.name === bname; });
          };
        }

        case 'on': {
          var onName = expectWord('a branch name after "on"');
          return function (ctx) { return ctx.graph.head === onName; };
        }

        case 'merged': {
          var from = expectWord('a branch name after "merged"');
          var into = peek();
          if (!into || String(into.v) !== 'into') {
            throw new Error('expected "merged ' + from + ' into <branch>" but found ' +
              describe(into) + ' after the branch name');
          }
          next();
          var target = expectWord('a branch name after "into"');
          // Ancestry alone would be trivially true the moment X is branched
          // off Y (X's tip is already an ancestor of Y's), so a real merge
          // must also have been recorded by the sandbox. The ancestry check
          // still matters: it goes false again if Y is later rewound past
          // the merge. When either branch no longer exists (deleted after
          // merging, or a remote-tracking name), the record alone decides.
          return function (ctx) {
            var recorded = (ctx.graph.merges || []).some(function (m) {
              return m.from === from && m.into === target;
            });
            if (!recorded) return false;
            var fromOid = branchOid(ctx, from);
            var intoOid = branchOid(ctx, target);
            if (!fromOid || !intoOid) return true;
            return reaches(ctx, intoOid, fromOid);
          };
        }

        case 'file': {
          var fname = expectWord('a filename after "file"');
          if (peek() && peek().t === 'word' && String(peek().v) === 'contains') {
            next();
            var needleTok = peek();
            if (!needleTok || (needleTok.t !== 'str' && needleTok.t !== 'word' && needleTok.t !== 'regex')) {
              throw new Error('expected text or /regex/ after "contains" but found ' + describe(needleTok));
            }
            next();
            if (needleTok.t === 'regex') {
              var fre = new RegExp(needleTok.v, needleTok.flags || '');
              return function (ctx) { return fre.test(ctx._fileText(fname)); };
            }
            var needle = String(needleTok.v);
            return function (ctx) { return ctx._fileText(fname).indexOf(needle) !== -1; };
          }
          return function (ctx) { return ctx.files.indexOf(fname) !== -1; };
        }

        case 'remote':
          return function (ctx) { return !!ctx.remote; };

        // true once the current branch's latest commit is on the remote
        case 'pushed':
          return function (ctx) {
            return !!(ctx.remote && ctx.remote.tracked && ctx.remote.ahead === 0);
          };

        case 'ran': {
          var rTok = peek();
          if (!rTok || (rTok.t !== 'regex' && rTok.t !== 'str' && rTok.t !== 'word')) {
            throw new Error('expected /regex/ or "text" after "ran" but found ' + describe(rTok));
          }
          next();
          if (rTok.t === 'regex') {
            var re = new RegExp(rTok.v, rTok.flags || '');
            return function (ctx) { return (ctx.history || []).some(function (h) { return re.test(h); }); };
          }
          var text = String(rTok.v);
          return function (ctx) {
            return (ctx.history || []).some(function (h) { return h.indexOf(text) !== -1; });
          };
        }

        default:
          throw new Error('unknown condition "' + word + '". Available: repo, clean, staged, ' +
            'commits, commits on <branch>, branch <name>, on <branch>, merged <a> into <b>, ' +
            'merge commit, file <name> [contains "text"], ran /regex/, remote, pushed');
      }
    }

    var fn = parseOr();
    if (pos < tokens.length) {
      throw new Error('unexpected ' + describe(peek()) + ' after a complete condition');
    }
    return fn;
  }

  /* -------------------------------- public ------------------------------- */

  function compileWhen(src) {
    if (typeof src !== 'string' || src.trim() === '') {
      throw new Error('`when:` is empty');
    }
    var fn;
    try {
      fn = parse(src);
    } catch (e) {
      throw new Error('cannot read `when: ' + src + '` — ' + e.message);
    }
    return function (ctx) {
      // `file ... contains` needs file contents, which are async; the UI
      // pre-loads them into ctx._files before evaluating.
      return fn(ctx);
    };
  }

  // Which filenames does this expression need the contents of? The UI reads
  // them before evaluating so predicates can stay synchronous.
  function filesNeeded(src) {
    var out = [];
    try {
      var tokens = tokenize(src);
      for (var i = 0; i < tokens.length - 2; i++) {
        if (tokens[i].t === 'word' && String(tokens[i].v) === 'file' &&
            tokens[i + 2] && tokens[i + 2].t === 'word' && String(tokens[i + 2].v) === 'contains') {
          out.push(String(tokens[i + 1].v));
        }
      }
    } catch (e) { /* compileWhen will report it */ }
    return out;
  }

  function compileJs(src) {
    var body = /(^|[\s;{])return[\s(]/.test(src) ? src : 'return (' + src + ');';
    try {
      /* eslint-disable no-new-func */
      var fn = new Function('c', body);
      return function (ctx) { return fn(ctx); };
    } catch (e) {
      throw new Error('cannot compile `js:` block — ' + e.message);
    }
  }

  return { compileWhen: compileWhen, compileJs: compileJs, filesNeeded: filesNeeded, tokenize: tokenize };
});


/* ------------------------------------------------------------------
   git sandbox UI: terminal + staging diagram + commit graph.
   Depends on window.GitSandboxCore and window.git (isomorphic-git UMD).
   ------------------------------------------------------------------ */
(function (root) {
  'use strict';

  var LANE_COLORS = ['#447099', '#419599', '#72994E', '#9A4665', '#EE6331', '#3276B5'];

  function esc(s) {
    return String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // {g} green {r} red {y} yellow {b} blue {w} bold {/} reset
  function markup(s) {
    var map = { g: 'tg', r: 'tr', y: 'ty', b: 'tb', w: 'tw' };
    var out = esc(s);
    out = out.replace(/\{([grybw])\}/g, function (_m, k) { return '<span class="' + map[k] + '">'; });
    out = out.replace(/\{\/\}/g, '</span>');
    return out;
  }

  /* --------------------- config normalisation ------------------------ */

  // Authors can describe a task three ways:
  //   check: async (c) => ...     a JavaScript predicate (hand-written qmd)
  //   when:  'commits >= 2'       the declarative mini-language (extension)
  //   js:    'c.isRepo'           an escape hatch for the extension
  // Normalise all three to a `check` function, recording any compile error so
  // it can be shown in place instead of failing silently.
  function normaliseTasks(tasks) {
    var W = root.GitSandboxWhen;
    return (tasks || []).map(function (t) {
      var task = { text: t.text, _done: false, _error: null, _files: [] };
      if (typeof t.check === 'function') {
        task.check = t.check;
        return task;
      }
      if (!W) {
        task._error = 'the `when:` compiler is not loaded';
        task.check = function () { return false; };
        return task;
      }
      try {
        if (typeof t.when === 'string' && t.when.trim() !== '') {
          task._files = W.filesNeeded(t.when);
          var pred = W.compileWhen(t.when);
          task.check = function (ctx) { return pred(ctx); };
        } else if (typeof t.js === 'string' && t.js.trim() !== '') {
          var jsPred = W.compileJs(t.js);
          task.check = function (ctx) { return jsPred(ctx); };
        } else {
          throw new Error('a task needs one of `when:`, `js:` or a `check` function');
        }
      } catch (e) {
        task._error = e.message;
        task.check = function () { return false; };
      }
      return task;
    });
  }

  // `seed` may be a function or a block of commands from YAML.
  function normaliseSeed(seed) {
    if (!seed) return null;
    if (typeof seed === 'function') return seed;
    var lines = String(seed).split('\n')
      .map(function (l) { return l.trim(); })
      .filter(function (l) { return l !== '' && l.charAt(0) !== '#'; });
    if (!lines.length) return null;
    return async function (sb) {
      for (var i = 0; i < lines.length; i++) {
        var r = await sb.run(lines[i]);
        if (!r.ok) {
          // A broken seed is an authoring bug, so make it loud rather than
          // leaving the learner in a half-built repository.
          throw new Error('seed command failed: ' + lines[i] + ' — ' + String(r.out).split('\n')[0]);
        }
      }
    };
  }

  function normaliseIntro(intro) {
    if (!intro) return [];
    if (Array.isArray(intro)) return intro;
    return String(intro).replace(/\n$/, '').split('\n');
  }

  function el(tag, cls, html) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (html != null) n.innerHTML = html;
    return n;
  }

  /* --------------------------- commit graph -------------------------- */

  function renderGraph(svg, model) {
    while (svg.firstChild) svg.removeChild(svg.firstChild);
    var NS = 'http://www.w3.org/2000/svg';

    // Draw at the SVG's real pixel width so nothing overflows sideways; the
    // graph never needs a horizontal scrollbar.
    var W = svg.clientWidth || 640;

    if (!model.commits.length) {
      svg.setAttribute('viewBox', '0 0 ' + W + ' 60');
      svg.setAttribute('height', '60');
      var t = document.createElementNS(NS, 'text');
      t.setAttribute('x', String(W / 2)); t.setAttribute('y', '34');
      t.setAttribute('text-anchor', 'middle');
      t.setAttribute('class', 'gs-empty-text');
      t.textContent = 'No commits yet.';
      svg.appendChild(t);
      return;
    }

    var rowH = 44, laneW = 24, padTop = 26, padLeft = 22, lineH = 17;
    var maxLane = 0;
    model.commits.forEach(function (c) { if (c.lane > maxLane) maxLane = c.lane; });
    var graphW = padLeft + maxLane * laneW + 22;

    // Wrap a commit message to a character budget, breaking on spaces and
    // hard-breaking any single word longer than the line.
    function wrapWords(text, maxChars) {
      var words = String(text).split(/\s+/), lines = [], cur = '';
      words.forEach(function (w) {
        if (!cur) cur = w;
        else if ((cur + ' ' + w).length <= maxChars) cur += ' ' + w;
        else { lines.push(cur); cur = w; }
      });
      if (cur) lines.push(cur);
      var out = [];
      lines.forEach(function (l) {
        while (l.length > maxChars) { out.push(l.slice(0, maxChars)); l = l.slice(maxChars); }
        out.push(l);
      });
      return out.length ? out : [''];
    }

    // First pass: place refs/sha/message per row and measure the wrapped height.
    var rows = model.commits.map(function (c) {
      var tx = graphW + 6;
      var refLayouts = (c.refs || []).map(function (r) {
        var label = (r.isHead ? 'HEAD → ' : '') + r.name;
        var w = label.length * 6.6 + 14;
        var lay = { label: label, x: tx, w: w, isHead: r.isHead, remote: r.remote };
        tx += w + 6;
        return lay;
      });
      var shaX = tx, msgX = tx + 62;
      var maxChars = Math.max(8, Math.floor((W - msgX - 12) / 6.8));
      var lines = wrapWords(c.message, maxChars);
      return { refLayouts: refLayouts, shaX: shaX, msgX: msgX, lines: lines,
               h: Math.max(rowH, lines.length * lineH + 20) };
    });

    // Second pass: stack rows so a wrapped message never overlaps the next.
    var tops = [], acc = padTop;
    rows.forEach(function (r) { tops.push(acc); acc += r.h; });
    var height = acc + 6;

    svg.setAttribute('viewBox', '0 0 ' + W + ' ' + height);
    svg.setAttribute('height', String(height));
    svg.setAttribute('preserveAspectRatio', 'xMinYMin meet');

    var index = {};
    model.commits.forEach(function (c, i) { index[c.oid] = i; });
    var x = function (lane) { return padLeft + lane * laneW; };
    var cyOf = function (i) { return tops[i] + 16; };

    // edges first so nodes sit on top
    model.commits.forEach(function (c, i) {
      (c.parents || []).forEach(function (p, pi) {
        if (!(p in index)) return;
        var j = index[p];
        var x1 = x(c.lane), y1 = cyOf(i), x2 = x(model.commits[j].lane), y2 = cyOf(j);
        var path = document.createElementNS(NS, 'path');
        var d;
        if (x1 === x2) {
          d = 'M' + x1 + ',' + y1 + ' L' + x2 + ',' + y2;
        } else {
          var mid = y1 + (y2 - y1) * 0.55;
          d = 'M' + x1 + ',' + y1 + ' C' + x1 + ',' + mid + ' ' + x2 + ',' + (y2 - (y2 - y1) * 0.45) + ' ' + x2 + ',' + y2;
        }
        path.setAttribute('d', d);
        path.setAttribute('fill', 'none');
        path.setAttribute('stroke', LANE_COLORS[(pi === 0 ? c.lane : model.commits[j].lane) % LANE_COLORS.length]);
        path.setAttribute('stroke-width', '2');
        path.setAttribute('opacity', '0.55');
        svg.appendChild(path);
      });
    });

    model.commits.forEach(function (c, i) {
      var cx = x(c.lane), cy = cyOf(i), row = rows[i];
      var isMerge = (c.parents || []).length > 1;

      var circle = document.createElementNS(NS, 'circle');
      circle.setAttribute('cx', cx); circle.setAttribute('cy', cy);
      circle.setAttribute('r', isMerge ? 7 : 6);
      circle.setAttribute('fill', isMerge ? '#FFFFFF' : LANE_COLORS[c.lane % LANE_COLORS.length]);
      circle.setAttribute('stroke', LANE_COLORS[c.lane % LANE_COLORS.length]);
      circle.setAttribute('stroke-width', isMerge ? '3' : '2');
      svg.appendChild(circle);

      // ref pills
      row.refLayouts.forEach(function (rl) {
        var rect = document.createElementNS(NS, 'rect');
        rect.setAttribute('x', rl.x); rect.setAttribute('y', cy - 10);
        rect.setAttribute('width', rl.w); rect.setAttribute('height', 20);
        rect.setAttribute('rx', 10);
        rect.setAttribute('fill', rl.isHead ? '#447099' : (rl.remote ? '#E7E9EC' : '#D0DBE5'));
        svg.appendChild(rect);
        var lt = document.createElementNS(NS, 'text');
        lt.setAttribute('x', rl.x + 7); lt.setAttribute('y', cy + 4);
        lt.setAttribute('class', rl.isHead ? 'gs-ref gs-ref-head' : (rl.remote ? 'gs-ref gs-ref-remote' : 'gs-ref'));
        lt.textContent = rl.label;
        svg.appendChild(lt);
      });

      var sha = document.createElementNS(NS, 'text');
      sha.setAttribute('x', row.shaX); sha.setAttribute('y', cy + 4);
      sha.setAttribute('class', 'gs-sha');
      sha.textContent = c.short;
      svg.appendChild(sha);

      var msg = document.createElementNS(NS, 'text');
      msg.setAttribute('y', cy + 4);
      msg.setAttribute('class', 'gs-msg');
      row.lines.forEach(function (line, li) {
        var ts = document.createElementNS(NS, 'tspan');
        ts.setAttribute('x', row.msgX);
        ts.setAttribute('dy', li === 0 ? '0' : String(lineH));
        ts.textContent = line;
        msg.appendChild(ts);
      });
      svg.appendChild(msg);
    });
  }

  /* ------------------------------ diff panel ------------------------- */

  function renderDiff(node, model) {
    if (!model) {
      node.innerHTML = '<div class="gs-diff-empty">Nothing is tracked yet — run <code>git init</code> to start.</div>';
      return;
    }
    if (!model.files.length) {
      node.innerHTML = '<div class="gs-diff-empty">Working directory clean — no changes since the last commit.</div>';
      return;
    }
    node.innerHTML = model.files.map(function (f) {
      var rows = f.lines.map(function (l) {
        var cls = l.t === '+' ? ' gs-diff-add' : (l.t === '-' ? ' gs-diff-del' : '');
        return '<div class="gs-diff-line' + cls + '">' +
          '<span class="gs-diff-num">' + (l.a || '') + '</span>' +
          '<span class="gs-diff-num">' + (l.b || '') + '</span>' +
          '<span class="gs-diff-sign">' + (l.t === ' ' ? '' : l.t) + '</span>' +
          '<span class="gs-diff-text">' + esc(l.text) + '</span>' +
        '</div>';
      }).join('');
      return '<div class="gs-diff-file">' +
        '<div class="gs-diff-filehead">' +
          '<span class="gs-diff-name">' + esc(f.file) + '</span>' +
          '<span class="gs-diff-kind gs-diff-kind-' + f.kind + '">' + f.kind + '</span>' +
        '</div>' + rows +
      '</div>';
    }).join('');
  }

  /* -------------------------- staging diagram ------------------------ */

  function renderStages(node, status, graph, files, isRepo) {
    var needAdd = []
      .concat(status.untracked.map(function (f) { return { f: f, k: 'untracked' }; }))
      .concat(status.modified.map(function (f) { return { f: f, k: 'modified' }; }))
      .concat(status.deleted.map(function (f) { return { f: f, k: 'deleted' }; }));
    var staged = status.staged.map(function (s) { return { f: s.file, k: s.kind }; })
      .concat(status.stagedDeleted.map(function (f) { return { f: f, k: 'deleted' }; }));

    // Files with no git status still need to be visible: committed-and-clean
    // files after init, and every file before it. Before `git init` they are
    // just files — calling them "untracked" would use a git-status word while
    // no git status exists yet — so they render as quiet grey chips either way.
    var accounted = {};
    needAdd.concat(staged).forEach(function (it) { accounted[it.f] = true; });
    var clean = (files || [])
      .filter(function (f) { return !accounted[f]; })
      .map(function (f) { return { f: f, k: isRepo ? 'unchanged' : 'not in git yet' }; });

    function col(title, note, items, kind) {
      var chips = items.length
        ? items.map(function (it) {
            var quiet = it.k === 'unchanged' || it.k === 'not in git yet';
            var cls = 'gs-chip gs-chip-' + kind + (quiet ? ' gs-chip-clean' : '');
            return '<span class="' + cls + '">' + esc(it.f) +
                   '<span class="gs-chip-k">' + esc(it.k) + '</span></span>';
          }).join('')
        : '<span class="gs-chip gs-chip-empty">empty</span>';
      return '<div class="gs-col">' +
             '<div class="gs-col-h">' + esc(title) + '</div>' +
             '<div class="gs-col-n">' + esc(note) + '</div>' +
             '<div class="gs-chips">' + chips + '</div></div>';
    }

    var nCommits = graph.commits.length;
    var repoItems = nCommits
      ? [{ f: nCommits + ' commit' + (nCommits === 1 ? '' : 's'), k: graph.head || 'detached' }]
      : [];

    node.innerHTML =
      col('Working directory', 'what you edit', needAdd.concat(clean), 'work') +
      '<div class="gs-arrow"><span>git add</span><i class="gs-arrow-g">→</i></div>' +
      col('Staging area', 'what goes in next commit', staged, 'stage') +
      '<div class="gs-arrow"><span>git commit</span><i class="gs-arrow-g">→</i></div>' +
      col('Repository', 'permanent history', repoItems, 'repo');
  }

  /* ------------------------------- mount ----------------------------- */

  function mount(selector, config) {
    config = config || {};
    var host = typeof selector === 'string' ? document.querySelector(selector) : selector;
    if (!host) return null;

    if (!root.git || typeof root.git.init !== 'function') {
      host.classList.add('gs');
      host.innerHTML = '<div class="gs-loading">This exercise could not start: the git library did not load. ' +
        'Check that isomorphic-git.bundle.js is reachable from this page.</div>';
      return null;
    }
    if (typeof root.Buffer === 'undefined') {
      // isomorphic-git's index code calls a global Buffer. The bundle shipped with
      // this lesson provides one; a bare CDN copy of isomorphic-git does not.
      host.classList.add('gs');
      host.innerHTML = '<div class="gs-loading">This exercise could not start: no Buffer polyfill is present. ' +
        'Load isomorphic-git.bundle.js (which includes one) rather than isomorphic-git on its own.</div>';
      return null;
    }

    var sb = root.GitSandboxCore.createSandbox({
      git: root.git,
      displayDir: (config.prompt || '~/project').replace(/\s*\$\s*$/, '')
    });
    var history = [];
    var histIdx = -1;
    var busy = false;
    var tasks = normaliseTasks(config.tasks);
    var seed = normaliseSeed(config.seed);
    var intro = normaliseIntro(config.intro);

    host.classList.add('gs');
    host.innerHTML =
      '<div class="gs-head">' +
        '<span class="gs-eyebrow">' + esc(config.title || 'Git sandbox') + '</span>' +
        '<span class="gs-state" role="status"></span>' +
        '<button type="button" class="gs-undo" disabled>Undo</button>' +
        '<button type="button" class="gs-reset">Reset</button>' +
      '</div>' +
      '<div class="gs-body">' +
        '<div class="gs-term-wrap">' +
          '<div class="gs-out" role="log" aria-live="polite" aria-label="Terminal output"></div>' +
          '<form class="gs-input-row" autocomplete="off">' +
            '<label class="gs-prompt" for="' + (host.id || 'gs') + '-in">' + esc(config.prompt || '~/project $') + '</label>' +
            '<input class="gs-input" id="' + (host.id || 'gs') + '-in" type="text" spellcheck="false"' +
            ' autocapitalize="off" autocorrect="off" aria-label="Type a git command"' +
            ' placeholder="type a command and press Enter">' +
          '</form>' +
          '<div class="gs-hints"></div>' +
        '</div>' +
        '<div class="gs-tasks"></div>' +
        '<div class="gs-viz">' +
          // One panel at a time; each tab carries a live badge so the folded
          // panels still tell you what they hold at a glance.
          '<div class="gs-tabs" role="tablist" aria-label="Repository views">' +
            '<button type="button" class="gs-tab is-active" role="tab" aria-selected="true" data-tab="files">Files<span class="gs-tab-badge" hidden></span></button>' +
            '<button type="button" class="gs-tab" role="tab" aria-selected="false" data-tab="changes">Changes<span class="gs-tab-badge" hidden></span></button>' +
            '<button type="button" class="gs-tab" role="tab" aria-selected="false" data-tab="history">History<span class="gs-tab-badge" hidden></span></button>' +
            '<button type="button" class="gs-tab" role="tab" aria-selected="false" data-tab="remote" hidden>Remote<span class="gs-tab-badge" hidden></span></button>' +
          '</div>' +
          '<section class="gs-panel" role="tabpanel" data-panel="files">' +
            '<div class="gs-stages"></div>' +
          '</section>' +
          '<section class="gs-panel" role="tabpanel" data-panel="changes" hidden>' +
            '<div class="gs-diff"></div>' +
          '</section>' +
          '<section class="gs-panel" role="tabpanel" data-panel="history" hidden>' +
            '<div class="gs-graph-scroll"><svg class="gs-graph" xmlns="http://www.w3.org/2000/svg"></svg></div>' +
          '</section>' +
          '<section class="gs-panel" role="tabpanel" data-panel="remote" hidden>' +
            '<div class="gs-remote" hidden>' +
              '<div class="gs-graph-scroll"><svg class="gs-remote-graph" xmlns="http://www.w3.org/2000/svg"></svg></div>' +
              '<div class="gs-remote-sync"></div>' +
            '</div>' +
          '</section>' +
        '</div>' +
      '</div>';

    var out = host.querySelector('.gs-out');
    var form = host.querySelector('.gs-input-row');
    var input = host.querySelector('.gs-input');
    var hintsNode = host.querySelector('.gs-hints');
    var stagesNode = host.querySelector('.gs-stages');
    var diffNode = host.querySelector('.gs-diff');
    var svg = host.querySelector('.gs-graph');
    var remoteWrap = host.querySelector('.gs-remote');
    var remoteSvg = host.querySelector('.gs-remote-graph');
    var remoteSync = host.querySelector('.gs-remote-sync');
    var tasksNode = host.querySelector('.gs-tasks');
    var stateNode = host.querySelector('.gs-state');
    var resetBtn = host.querySelector('.gs-reset');
    var undoBtn = host.querySelector('.gs-undo');
    var lastStateHtml = '';

    // Undo is full time travel: each entry restores the repo, the task
    // ticks, the command history and the terminal together, so the undone
    // command leaves no trace anywhere. Only commands that actually changed
    // state get an entry, so `undo` never appears to do nothing.
    var undoStack = [];
    var UNDO_DEPTH = 20;

    function captureUndo(line) {
      return {
        line: line,
        core: sb.snapshot(),
        outHtml: out.innerHTML,
        prompt: host.querySelector('.gs-prompt').textContent,
        histLen: history.length,
        done: tasks.map(function (t) { return !!t._done; })
      };
    }

    function doUndo() {
      var entry = undoStack.pop();
      if (!entry) {
        write('<span class="gs-echo-prompt">' +
          esc(host.querySelector('.gs-prompt').textContent) + '</span> undo', 'gs-echo');
        writeText('Nothing to undo.');
        return;
      }
      sb.restore(entry.core);
      out.innerHTML = entry.outHtml;
      history.length = entry.histLen;
      histIdx = history.length;
      tasks.forEach(function (t, i) { t._done = entry.done[i]; t._wasDone = entry.done[i]; });
      write('<span class="gs-echo-prompt">' + esc(entry.prompt) + '</span> undo', 'gs-echo');
      writeText('Undid: {y}' + entry.line + '{/}');
    }

    /* ------------------------------ tabs ------------------------------ */

    var tabButtons = {};
    var tabPanels = {};
    host.querySelectorAll('.gs-tab').forEach(function (b) { tabButtons[b.getAttribute('data-tab')] = b; });
    host.querySelectorAll('.gs-panel').forEach(function (p) { tabPanels[p.getAttribute('data-panel')] = p; });
    var activeTab = 'files';

    function selectTab(name) {
      if (!tabButtons[name] || tabButtons[name].hidden) return;
      activeTab = name;
      Object.keys(tabButtons).forEach(function (k) {
        var on = k === name;
        tabButtons[k].classList.toggle('is-active', on);
        tabButtons[k].setAttribute('aria-selected', on ? 'true' : 'false');
        tabPanels[k].hidden = !on;
      });
      // A graph drawn while its panel was hidden used the fallback width;
      // now that it has a real width, redraw at it.
      redrawGraph();
    }

    Object.keys(tabButtons).forEach(function (k) {
      tabButtons[k].addEventListener('click', function () { selectTab(k); });
    });

    function setBadge(name, text) {
      var badge = tabButtons[name].querySelector('.gs-tab-badge');
      badge.hidden = !text;
      badge.textContent = text || '';
      badge.classList.toggle('gs-tab-badge-ok', text === '✓');
    }

    // Which tab would a learner look at after this command? Mirrors the
    // glance they'd make anyway; a manual tab click holds until the next
    // command that has an opinion.
    function tabFor(line) {
      var t = line.trim().split(/\s+/);
      var c = t[0], s = t[1] || '';
      if (c === 'git') {
        if (/^(init|add|rm|status|restore|mv)$/.test(s)) return 'files';
        if (s === 'diff') return 'changes';
        if (/^(commit|merge|log|branch|checkout|switch)$/.test(s)) return 'history';
        if (/^(push|pull|fetch|remote)$/.test(s)) return 'remote';
        return null;
      }
      if (/^(echo|touch|rm|mkdir)$/.test(c)) return 'files';
      return null;
    }

    // The graph is drawn at the SVG's current pixel width, so a later resize
    // would scale it like an image (tiny text on narrow screens). Redraw the
    // last model whenever the width actually changes.
    var lastGraph = null;
    var lastGraphW = 0;
    var lastRemoteGraph = null;
    var lastRemoteGraphW = 0;
    function redrawGraph() {
      var w = svg.clientWidth;
      if (lastGraph && w && w !== lastGraphW) {
        lastGraphW = w;
        renderGraph(svg, lastGraph);
      }
      var rw = remoteSvg.clientWidth;
      if (lastRemoteGraph && rw && rw !== lastRemoteGraphW) {
        lastRemoteGraphW = rw;
        renderGraph(remoteSvg, lastRemoteGraph);
      }
    }
    if (typeof ResizeObserver !== 'undefined') {
      new ResizeObserver(redrawGraph).observe(svg.parentNode);
    } else {
      root.addEventListener('resize', redrawGraph);
    }

    function write(html, cls) {
      var line = el('div', 'gs-line' + (cls ? ' ' + cls : ''), html);
      out.appendChild(line);
      out.scrollTop = out.scrollHeight;
    }
    function writeText(text, cls) {
      if (text === '' || text == null) return;
      write(markup(text), cls);
    }

    function renderHints() {
      var hints = config.hints || [];
      if (!hints.length) { hintsNode.innerHTML = ''; return; }
      hintsNode.innerHTML = '<span class="gs-hints-label">Try:</span>';
      hints.forEach(function (h) {
        var b = el('button', 'gs-hint', esc(h));
        b.type = 'button';
        b.addEventListener('click', function () { input.value = h; input.focus(); });
        hintsNode.appendChild(b);
      });
    }

    function renderTasks() {
      if (!tasks.length) { tasksNode.innerHTML = ''; return; }
      var done = 0;
      var rows = tasks.map(function (t) {
        if (t._error) {
          return '<li class="gs-task gs-task-broken">' +
                 '<span class="gs-task-mark" aria-hidden="true">!</span>' +
                 '<span class="gs-task-txt">' + t.text +
                 '<span class="gs-task-err">Authoring error: ' + esc(t._error) + '</span></span></li>';
        }
        var ok = !!t._done;
        if (ok) done++;
        // A task that ticked on this render gets a brief highlight, so the
        // completion registers even while the eye is on the terminal.
        var fresh = ok && !t._wasDone;
        t._wasDone = ok;
        return '<li class="gs-task' + (ok ? ' is-done' : '') + (fresh ? ' is-just-done' : '') + '">' +
               '<span class="gs-task-mark" aria-hidden="true">' + (ok ? '✓' : '') + '</span>' +
               '<span class="gs-task-txt">' + t.text + '</span></li>';
      }).join('');
      var broken = tasks.some(function (t) { return !!t._error; });
      var all = !broken && done === tasks.length;
      var note = config.doneNote || 'That is the whole exercise.';
      tasksNode.innerHTML =
        '<div class="gs-tasks-h">Your turn <span class="gs-count">' + done + ' of ' + tasks.length + '</span></div>' +
        '<ul class="gs-task-list">' + rows + '</ul>' +
        (all ? '<div class="gs-done">' + note + '</div>' : '');
    }

    async function refresh() {
      var graph = await sb.graphModel();
      var isRepo = await sb.isRepo();
      var status = isRepo ? await sb.statusModel()
        : { staged: [], modified: [], untracked: [], deleted: [], stagedDeleted: [] };
      var files = await sb.listFiles();
      var diff = await sb.diffModel();
      renderStages(stagesNode, status, graph, files, isRepo);
      renderDiff(diffNode, diff);
      renderGraph(svg, graph);
      lastGraph = graph;
      lastGraphW = svg.clientWidth;

      var remote = await sb.remoteModel();
      if (remote) {
        remoteWrap.hidden = false;
        renderGraph(remoteSvg, remote.graph);
        lastRemoteGraph = remote.graph;
        lastRemoteGraphW = remoteSvg.clientWidth;
        remoteSync.innerHTML = remoteSyncText(remote);
      } else {
        remoteWrap.hidden = true;
        lastRemoteGraph = null;
        remoteSync.innerHTML = '';
      }

      // Tab badges: enough signal that folded panels lose nothing you would
      // catch at a glance. A count means "something here"; ✓ means clean.
      var changed = status.untracked.length + status.modified.length +
        status.deleted.length + status.staged.length + status.stagedDeleted.length;
      setBadge('files', isRepo ? (changed ? String(changed) : '✓')
        : (files.length ? String(files.length) : ''));
      setBadge('changes', !isRepo ? '' : (diff && diff.files.length ? String(diff.files.length) : '✓'));
      setBadge('history', graph.commits.length ? String(graph.commits.length) : '');
      tabButtons.remote.hidden = !remote;
      if (remote) {
        setBadge('remote', !remote.tracked ? ''
          : (!remote.ahead && !remote.behind) ? '✓'
          : ((remote.ahead ? '⇡' + remote.ahead : '') +
             (remote.ahead && remote.behind ? ' ' : '') +
             (remote.behind ? '⇣' + remote.behind : '')));
      } else if (activeTab === 'remote') {
        selectTab('files');
      }

      var stateHtml = !isRepo
        ? '<span class="gs-state-pill gs-state-none">○ no repository</span>'
        : '<span class="gs-state-pill gs-state-repo">● repository</span>' +
          (remote ? '<span class="gs-state-pill gs-state-remote">⇄ origin</span>' : '');
      // role="status" announces DOM changes, so only touch it on a real change.
      if (stateHtml !== lastStateHtml) {
        stateNode.innerHTML = stateHtml;
        lastStateHtml = stateHtml;
      }

      // `file x contains "y"` needs file contents; read them up front so the
      // compiled predicates can stay synchronous.
      var contents = {};
      for (var f = 0; f < tasks.length; f++) {
        for (var g = 0; g < (tasks[f]._files || []).length; g++) {
          var name = tasks[f]._files[g];
          if (name in contents) continue;
          try { contents[name] = await sb.readFile(name); }
          catch (e) { contents[name] = ''; }
        }
      }

      var ctx = {
        sb: sb, graph: graph, status: status, files: files,
        history: history, isRepo: isRepo, remote: remote,
        _fileText: function (name) { return contents[name] || ''; }
      };
      for (var i = 0; i < tasks.length; i++) {
        if (tasks[i]._done || tasks[i]._error) continue;
        try { tasks[i]._done = !!(await tasks[i].check(ctx)); }
        catch (e) { tasks[i]._done = false; }
      }
      renderTasks();

      undoBtn.disabled = !undoStack.length;

      var br = graph.head;
      var promptText = (config.prompt || '~/project') .replace(/\s*\$\s*$/, '');
      host.querySelector('.gs-prompt').textContent =
        promptText + (br ? ' (' + br + ')' : '') + ' $';
    }

    async function submit(line) {
      if (busy) return;
      busy = true;
      input.disabled = true;
      var trimmed = line.trim();
      if (trimmed === 'undo') {
        // never reaches the engine: undo is a sandbox affordance, not git
        doUndo();
        await refresh();
        input.disabled = false;
        busy = false;
        input.focus();
        return;
      }
      var snap = captureUndo(line);
      write('<span class="gs-echo-prompt">' + esc(host.querySelector('.gs-prompt').textContent) + '</span> ' + esc(line), 'gs-echo');
      history.push(line);
      histIdx = history.length;
      var r = await sb.run(line);
      if (trimmed === 'clear') { out.innerHTML = ''; }
      else if (trimmed === 'help') { writeText(helpText()); }
      else if (trimmed === 'reset') { await doReset(); }
      else { writeText(r.out, r.ok ? '' : 'gs-err'); }
      if (r.ok && trimmed !== 'reset' && sb.changedSince(snap.core)) {
        undoStack.push(snap);
        if (undoStack.length > UNDO_DEPTH) undoStack.shift();
      }
      await refresh();
      if (r.ok) {
        var want = tabFor(line);
        if (want) selectTab(want);
      }
      input.disabled = false;
      busy = false;
      input.focus();
    }

    // one-line summary under the remote graph: how the learner's current
    // branch compares to its counterpart on the remote
    function remoteSyncText(r) {
      if (!r.branch || !r.tracked) return '';
      var b = esc(r.branch);
      var n = function (k) { return k + ' commit' + (k === 1 ? '' : 's'); };
      if (!r.ahead && !r.behind) return '✓ in sync with your <code>' + b + '</code>';
      if (r.ahead && r.behind) return '<code>origin/' + b + '</code> and your <code>' + b + '</code> have diverged — <code>git pull</code>, then <code>git push</code>';
      if (r.behind) return '<code>origin/' + b + '</code> is ' + n(r.behind) + ' ahead of your <code>' + b + '</code> — <code>git pull</code> to update';
      return 'your <code>' + b + '</code> is ' + n(r.ahead) + ' ahead — <code>git push</code> to publish';
    }

    function helpText() {
      return [
        '{w}This sandbox runs real git{/} (isomorphic-git) on a repo that lives only in this page.',
        '',
        '{y}git{/}    init, status, add, commit -m, log [--oneline], diff,',
        '       branch [-d], checkout [-b], switch [-c], merge, config,',
        '       remote add origin, push [-u], pull, fetch',
        '{y}shell{/}  ls, cat, echo "text" > file, echo "text" >> file, touch, rm, mkdir, pwd',
        '{y}other{/}  help, clear, reset, undo',
        '',
        '{y}undo{/} takes back your last state-changing command (a sandbox',
        'nicety, not a git command — real git has no undo).'
      ].join('\n');
    }

    async function doReset() {
      out.innerHTML = '';
      input.value = '';
      // Tasks checked with `ran "..."` read the command history, so it has to
      // go too or they re-complete themselves on the very next refresh.
      history.length = 0;
      histIdx = 0;
      undoStack.length = 0;
      tasks.forEach(function (t) { t._done = false; t._wasDone = false; });
      selectTab('files');
      try {
        await sb.reset(seed);
      } catch (e) {
        writeText('{r}This exercise could not be set up: ' + e.message + '{/}', 'gs-err');
        await refresh();
        return;
      }
      intro.forEach(function (l) { writeText(l); });
      await refresh();
    }

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var v = input.value;
      input.value = '';
      if (!v.trim()) return;
      submit(v);
    });

    input.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowUp') {
        if (!history.length) return;
        e.preventDefault();
        histIdx = Math.max(0, histIdx - 1);
        input.value = history[histIdx] || '';
      } else if (e.key === 'ArrowDown') {
        if (!history.length) return;
        e.preventDefault();
        histIdx = Math.min(history.length, histIdx + 1);
        input.value = history[histIdx] || '';
      }
    });

    resetBtn.addEventListener('click', function () { doReset(); });
    undoBtn.addEventListener('click', function () { submit('undo'); });
    host.querySelector('.gs-out').addEventListener('click', function () { input.focus(); });

    renderHints();
    var ready = doReset();

    return { sandbox: sb, refresh: refresh, run: submit, ready: ready, tasks: tasks };
  }

  /* ------------------- helpers for exercise checks ------------------- */

  // oid a branch currently points at, or null
  function branchOid(graph, name) {
    var b = (graph.branches || []).filter(function (x) { return x.name === name; })[0];
    return b ? b.oid : null;
  }

  // is `target` reachable by walking parents back from `from`?
  function reaches(graph, from, target) {
    if (!from || !target) return false;
    if (from === target) return true;
    var byOid = {};
    graph.commits.forEach(function (c) { byOid[c.oid] = c; });
    var stack = [from];
    var seen = {};
    while (stack.length) {
      var oid = stack.pop();
      if (oid === target) return true;
      if (seen[oid]) continue;
      seen[oid] = true;
      var c = byOid[oid];
      if (c) (c.parents || []).forEach(function (p) { stack.push(p); });
    }
    return false;
  }

  // Has branch `name` been merged into branch `into`? Requires a merge the
  // sandbox actually recorded, not just ancestry — a branch freshly created
  // from `into`'s tip is already an ancestor of it, and a completed
  // fast-forward merge leaves the identical graph, so ancestry alone cannot
  // tell the two apart.
  function isMerged(graph, name, into) {
    var recorded = (graph.merges || []).some(function (m) {
      return m.from === name && m.into === into;
    });
    if (!recorded) return false;
    var fromOid = branchOid(graph, name);
    var intoOid = branchOid(graph, into);
    if (!fromOid || !intoOid) return true;
    return reaches(graph, intoOid, fromOid);
  }

  // how many commits are reachable from a branch tip
  function commitCount(graph, name) {
    var tip = branchOid(graph, name);
    if (!tip) return 0;
    var byOid = {};
    graph.commits.forEach(function (c) { byOid[c.oid] = c; });
    var stack = [tip], seen = {}, n = 0;
    while (stack.length) {
      var oid = stack.pop();
      if (seen[oid]) continue;
      seen[oid] = true; n++;
      var c = byOid[oid];
      if (c) (c.parents || []).forEach(function (p) { stack.push(p); });
    }
    return n;
  }

  function hasMergeCommit(graph) {
    return graph.commits.some(function (c) { return (c.parents || []).length > 1; });
  }

  function boot() {
    var pending = root.__gsPending || [];
    pending.forEach(function (p) { mount(p[0], p[1]); });
    root.__gsPending = { push: function (p) { mount(p[0], p[1]); } };
  }

  root.GitSandboxUI = {
    mount: mount,
    boot: boot,
    branchOid: branchOid,
    reaches: reaches,
    isMerged: isMerged,
    commitCount: commitCount,
    hasMergeCommit: hasMergeCommit
  };
})(window);
