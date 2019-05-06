<script type="text/javascript">
  let name = window.location.href;
  let idArray = name.split('/');
  let id = idArray[idArray.length - 2];
  id = id.slice(0, 20);
  const gitment = new Gitmint({
    id: id,
    owner: 'xgfe',
    admin: ['lulutia', 'Catherine33'],
    repo: 'xgfe.github.io',
    oauth: {
      redirect_protocol: 'https',
      client_id: '23cc0db4fc1491f8ae2e',
      client_secret: '13f4c4623bf8acb0479801903c80a71fdff0350e',
    }
  })
  gitment.render('comments')
</script>
