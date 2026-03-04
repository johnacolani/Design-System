/// Copy-paste ready code for UI Lab components (Flutter, SwiftUI, Jetpack Compose, React).
/// Key: "categoryId.storyId" → map of platform → code string.
Map<String, Map<String, String>> getUILabCodeSnippets() {
  return {
    'buttons.primary': {
      'flutter': '''ElevatedButton(
  onPressed: () {},
  child: const Text('Primary Button'),
)''',
      'swiftui': '''Button("Primary Button") {
    // action
}
.buttonStyle(.borderedProminent)''',
      'compose': '''Button(
  onClick = { },
  modifier = Modifier.fillMaxWidth()
) {
  Text("Primary Button")
}''',
      'react': '''<Button variant="contained" onClick={() => {}}>
  Primary Button
</Button>''',
    },
    'buttons.secondary': {
      'flutter': '''OutlinedButton(
  onPressed: () {},
  child: const Text('Outlined Button'),
)''',
      'swiftui': '''Button("Outlined Button") {
    // action
}
.buttonStyle(.bordered)''',
      'compose': '''OutlinedButton(
  onClick = { },
  modifier = Modifier.fillMaxWidth()
) {
  Text("Outlined Button")
}''',
      'react': '''<Button variant="outlined" onClick={() => {}}>
  Outlined Button
</Button>''',
    },
    'buttons.text': {
      'flutter': '''TextButton(
  onPressed: () {},
  child: const Text('Text Button'),
)''',
      'swiftui': '''Button("Text Button") {
    // action
}
.buttonStyle(.plain)''',
      'compose': '''TextButton(onClick = { }) {
  Text("Text Button")
}''',
      'react': '''<Button variant="text" onClick={() => {}}>
  Text Button
</Button>''',
    },
    'buttons.icon': {
      'flutter': '''IconButton(
  onPressed: () {},
  icon: const Icon(Icons.favorite_border),
  tooltip: 'Like',
)''',
      'swiftui': '''Button {
    // action
} label: {
  Image(systemName: "heart")
}
.buttonStyle(.plain)''',
      'compose': '''IconButton(onClick = { }) {
  Icon(Icons.Default.FavoriteBorder, null)
}''',
      'react': '''<IconButton onClick={() => {}}>
  <FavoriteBorderIcon />
</IconButton>''',
    },
    'buttons.fab': {
      'flutter': '''FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
)''',
      'swiftui': '''Button {
    // action
} label: {
  Image(systemName: "plus")
}
.buttonStyle(.circular)''',
      'compose': '''FloatingActionButton(
  onClick = { },
  shape = CircleShape()
) {
  Icon(Icons.Default.Add, null)
}''',
      'react': '''<Fab color="primary" onClick={() => {}}>
  <AddIcon />
</Fab>''',
    },
    'buttons.disabled': {
      'flutter': '''ElevatedButton(
  onPressed: null,
  child: const Text('Disabled'),
)''',
      'swiftui': '''Button("Disabled") { }
  .disabled(true)
  .buttonStyle(.borderedProminent)''',
      'compose': '''Button(
  onClick = { },
  enabled = false
) {
  Text("Disabled")
}''',
      'react': '''<Button variant="contained" disabled>
  Disabled
</Button>''',
    },
    'buttons.sizes': {
      'flutter': '''ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 20),
  ),
  child: const Text('Large'),
)''',
      'swiftui': '''Button("Large") { }
  .buttonStyle(.borderedProminent)
  .controlSize(.large)''',
      'compose': '''Button(
  onClick = { },
  modifier = Modifier.height(48.dp)
) {
  Text("Large")
}''',
      'react': '''<Button variant="contained" size="large">
  Large
</Button>''',
    },
    'inputs.outlined': {
      'flutter': '''TextField(
  decoration: InputDecoration(
    labelText: 'Outlined',
    hintText: 'Type here…',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)''',
      'swiftui': '''TextField("Type here…", text: \$binding)
  .textFieldStyle(.roundedBorder)''',
      'compose': '''OutlinedTextField(
  value = value,
  onValueChange = { value = it },
  label = { Text("Outlined") },
  modifier = Modifier.fillMaxWidth()
)''',
      'react': '''<TextField
  label="Outlined"
  variant="outlined"
  value={value}
  onChange={(e) => setValue(e.target.value)}
/>''',
    },
    'inputs.filled': {
      'flutter': '''TextField(
  decoration: InputDecoration(
    labelText: 'Filled',
    filled: true,
    border: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)''',
      'swiftui': '''TextField("Type here…", text: \$binding)
  .textFieldStyle(.roundedBorder)''',
      'compose': '''TextField(
  value = value,
  onValueChange = { value = it },
  modifier = Modifier.fillMaxWidth()
)''',
      'react': '''<TextField
  label="Filled"
  variant="filled"
  value={value}
  onChange={(e) => setValue(e.target.value)}
/>''',
    },
    'inputs.error': {
      'flutter': '''TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    errorText: 'Invalid email',
    border: OutlineInputBorder(),
  ),
)''',
      'swiftui': '''TextField("you@example.com", text: \$binding)
  .overlay(alignment: .bottomLeading) {
    Text("Invalid email").foregroundStyle(.red)
  }''',
      'compose': '''TextField(
  value = value,
  onValueChange = { value = it },
  isError = true,
  supportingText = { Text("Invalid email") }
)''',
      'react': '''<TextField
  label="Email"
  error
  helperText="Invalid email"
  value={value}
  onChange={(e) => setValue(e.target.value)}
/>''',
    },
    'inputs.multiline': {
      'flutter': '''TextField(
  maxLines: 4,
  decoration: InputDecoration(
    labelText: 'Description',
    alignLabelWithHint: true,
    border: OutlineInputBorder(),
  ),
)''',
      'swiftui': '''TextEditor(text: \$binding)
  .frame(height: 100)''',
      'compose': '''OutlinedTextField(
  value = value,
  onValueChange = { value = it },
  minLines = 4,
  modifier = Modifier.fillMaxWidth()
)''',
      'react': '''<TextField
  label="Description"
  multiline
  rows={4}
  value={value}
  onChange={(e) => setValue(e.target.value)}
/>''',
    },
    'cards.elevated': {
      'flutter': '''Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Text('Card content'),
      ],
    ),
  ),
)''',
      'swiftui': '''VStack(alignment: .leading) {
  Text("Title").font(.headline)
  Text("Card content")
}
.padding()
.background(.regularMaterial)''',
      'compose': '''Card(
  modifier = Modifier.fillMaxWidth(),
  elevation = 2.dp
) {
  Column(Modifier.padding(16.dp)) {
    Text("Title", style = MaterialTheme.typography.titleMedium)
    Spacer(Modifier.height(8.dp))
    Text("Card content")
  }
}''',
      'react': '''<Card>
  <CardContent>
    <Typography variant="h6">Title</Typography>
    <Typography>Card content</Typography>
  </CardContent>
</Card>''',
    },
    'cards.outlined': {
      'flutter': '''Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(padding: EdgeInsets.all(16), child: Text('Content')),
)''',
      'swiftui': '''VStack { Text("Content") }
  .padding()
  .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray))''',
      'compose': '''Card(
  modifier = Modifier.fillMaxWidth(),
  border = BorderStroke(1.dp, Color.Gray),
  shape = RoundedCornerShape(12.dp)
) {
  Text("Content", Modifier.padding(16.dp))
}''',
      'react': '''<Card variant="outlined">
  <CardContent>Content</CardContent>
</Card>''',
    },
    'cards.list': {
      'flutter': '''Card(
  child: Column(
    children: [
      ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text('Title'),
        subtitle: Text('Subtitle'),
        onTap: () {},
      ),
      Divider(height: 1),
      ListTile(leading: Icon(Icons.settings), title: Text('Settings'), onTap: () {}),
    ],
  ),
)''',
      'swiftui': '''List {
  Label("Title", systemImage: "person")
  Divider()
  Label("Settings", systemImage: "gear")
}
.listStyle(.insetGrouped)''',
      'compose': '''Card {
  Column {
    ListItem(
      headlineContent = { Text("Title") },
      supportingContent = { Text("Subtitle") },
      leadingContent = { Icon(Icons.Default.Person) }
    )
    HorizontalDivider()
    ListItem(
      headlineContent = { Text("Settings") },
      leadingContent = { Icon(Icons.Default.Settings) }
    )
  }
}''',
      'react': '''<Card>
  <List>
    <ListItem><ListItemAvatar><Avatar /></ListItemAvatar>
      <ListItemText primary="Title" secondary="Subtitle" /></ListItem>
    <Divider />
    <ListItem><ListItemIcon><SettingsIcon /></ListItemIcon>
      <ListItemText primary="Settings" /></ListItem>
  </List>
</Card>''',
    },
    'cards.actions': {
      'flutter': '''Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () {}, child: Text('Cancel')),
            SizedBox(width: 8),
            ElevatedButton(onPressed: () {}, child: Text('Save')),
          ],
        ),
      ],
    ),
  ),
)''',
      'swiftui': '''VStack(alignment: .leading) {
  Text("Title").font(.headline)
  HStack {
    Spacer()
    Button("Cancel") { }.buttonStyle(.plain)
    Button("Save") { }.buttonStyle(.borderedProminent)
  }
}
.padding()''',
      'compose': '''Card {
  Column(Modifier.padding(16.dp)) {
    Text("Title", style = MaterialTheme.typography.titleMedium)
    Spacer(Modifier.height(16.dp))
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
      TextButton({ }) { Text("Cancel") }
      Spacer(Modifier.width(8.dp))
      Button({ }) { Text("Save") }
    }
  }
}''',
      'react': '''<Card>
  <CardContent>
    <Typography variant="h6">Title</Typography>
    <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1, mt: 2 }}>
      <Button>Cancel</Button>
      <Button variant="contained">Save</Button>
    </Box>
  </CardContent>
</Card>''',
    },
    'navigation.appbar': {
      'flutter': '''AppBar(
  title: Text('Title'),
  actions: [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
  ],
)''',
      'swiftui': '''NavigationStack {
  content
  .navigationTitle("Title")
  .toolbar {
    ToolbarItem(placement: .primaryAction) {
      Button { } label: { Image(systemName: "magnifyingglass") }
    }
  }
}''',
      'compose': '''TopAppBar(
  title = { Text("Title") },
  actions = {
    IconButton({ }) { Icon(Icons.Default.Search, null) }
    IconButton({ }) { Icon(Icons.Default.MoreVert, null) }
  }
)''',
      'react': '''<AppBar>
  <Toolbar>
    <Typography variant="h6">Title</Typography>
    <IconButton><SearchIcon /></IconButton>
    <IconButton><MoreVertIcon /></IconButton>
  </Toolbar>
</AppBar>''',
    },
    'navigation.bottomnav': {
      'flutter': '''NavigationBar(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  destinations: [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ],
)''',
      'swiftui': '''TabView(selection: \$selection) {
  HomeView().tag(0)
  SearchView().tag(1)
  ProfileView().tag(2)
}
.tabViewStyle(.page)
.toolbar(.hidden, for: .tabBar)
safeAreaInset(edge: .bottom) {
  Picker("", selection: \$selection) {
    Text("Home").tag(0)
    Text("Search").tag(1)
    Text("Profile").tag(2)
  }
  .pickerStyle(.segmented)
}''',
      'compose': '''NavigationBar {
  NavigationBarItem(
    icon = { Icon(Icons.Default.Home, null) },
    label = { Text("Home") },
    selected = index == 0,
    onClick = { index = 0 }
  )
  // ... more items
}''',
      'react': '''<BottomNavigation value={value} onChange={(e, v) => setValue(v)}>
  <BottomNavigationItem label="Home" icon={<HomeIcon />} />
  <BottomNavigationItem label="Search" icon={<SearchIcon />} />
  <BottomNavigationItem label="Profile" icon={<PersonIcon />} />
</BottomNavigation>''',
    },
    'navigation.navrail': {
      'flutter': '''NavigationRail(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  destinations: [
    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
  ],
)''',
      'swiftui': '''NavigationSplitView {
  List(selection: \$selection) {
    Label("Home", systemImage: "house").tag(0)
    Label("Settings", systemImage: "gear").tag(1)
  }
  detail: { detailContent }
}''',
      'compose': '''NavigationRail(
  selectedItemIndex = index,
  onItemSelected = { index = it }
) {
  NavigationRailItem(
    icon = { Icon(Icons.Default.Home, null) },
    label = { Text("Home") },
    selected = index == 0,
    onClick = { index = 0 }
  )
}''',
      'react': '''<NavigationRail value={value} onChange={setValue}>
  <NavigationRailItem icon={<HomeIcon />} label="Home" />
  <NavigationRailItem icon={<SettingsIcon />} label="Settings" />
</NavigationRail>''',
    },
    'navigation.drawer': {
      'flutter': '''Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Text('Header', style: TextStyle(color: Colors.white)),
      ),
      ListTile(leading: Icon(Icons.home), title: Text('Home'), onTap: () {}),
      ListTile(leading: Icon(Icons.settings), title: Text('Settings'), onTap: () {}),
    ],
  ),
)''',
      'swiftui': '''NavigationSplitView(columnVisibility: \$visible) {
  List {
    Label("Home", systemImage: "house")
    Label("Settings", systemImage: "gear")
  }
  .navigationSplitViewColumnWidth(240)
  detail: { detailContent }
}''',
      'compose': '''ModalDrawer(
  drawerContent = {
    Column {
      Box(Modifier.fillMaxWidth().height(180.dp).background(Color.Blue)) {
        Text("Header", color = Color.White)
      }
      ListItem(headlineContent = { Text("Home") }, leadingContent = { Icon(Icons.Default.Home, null) })
      ListItem(headlineContent = { Text("Settings") }, leadingContent = { Icon(Icons.Default.Settings, null) })
    }
  }
) { content() }''',
      'react': '''<Drawer open={open} onClose={() => setOpen(false)}>
  <List>
    <ListItem><ListItemIcon><HomeIcon /></ListItemIcon><ListItemText primary="Home" /></ListItem>
    <ListItem><ListItemIcon><SettingsIcon /></ListItemIcon><ListItemText primary="Settings" /></ListItem>
  </List>
</Drawer>''',
    },
    'navigation.breadcrumb': {
      'flutter': '''Wrap(
  spacing: 4,
  children: [
    TextButton(onPressed: () {}, child: Text('Home')),
    Text(' / ', style: TextStyle(color: Colors.grey)),
    TextButton(onPressed: () {}, child: Text('Products')),
    Text(' / ', style: TextStyle(color: Colors.grey)),
    Text('Detail', style: TextStyle(fontWeight: FontWeight.bold)),
  ],
)''',
      'swiftui': '''HStack {
  Button("Home") { }
  Text("/")
  Button("Products") { }
  Text("/")
  Text("Detail").fontWeight(.semibold)
}''',
      'compose': '''Row(verticalAlignment = Alignment.CenterVertically) {
  TextButton({ }) { Text("Home") }
  Text("/")
  TextButton({ }) { Text("Products") }
  Text("/")
  Text("Detail", fontWeight = FontWeight.SemiBold)
}''',
      'react': '''<Breadcrumbs>
  <Link href="#">Home</Link>
  <Link href="#">Products</Link>
  <Typography color="textPrimary">Detail</Typography>
</Breadcrumbs>''',
    },
    'dialogs.alert': {
      'flutter': '''showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text('Alert'),
    content: Text('Message'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
    ],
  ),
);''',
      'swiftui': '''.alert("Alert", isPresented: \$showing) {
  Button("OK") { showing = false }
} message: {
  Text("Message")
}''',
      'compose': '''AlertDialog(
  onDismissRequest = { },
  title = { Text("Alert") },
  text = { Text("Message") },
  confirmButton = { TextButton({ }) { Text("OK") } }
)''',
      'react': '''<Dialog open={open} onClose={() => setOpen(false)}>
  <DialogTitle>Alert</DialogTitle>
  <DialogContent>Message</DialogContent>
  <DialogActions>
    <Button onClick={() => setOpen(false)}>OK</Button>
  </DialogActions>
</Dialog>''',
    },
    'dialogs.simple': {
      'flutter': '''showDialog(
  context: context,
  builder: (ctx) => SimpleDialog(
    title: Text('Choose'),
    children: [
      SimpleDialogOption(onPressed: () => Navigator.pop(ctx), child: Text('Option A')),
      SimpleDialogOption(onPressed: () => Navigator.pop(ctx), child: Text('Option B')),
    ],
  ),
);''',
      'swiftui': '''.confirmationDialog("Choose", isPresented: \$showing) {
  Button("Option A") { }
  Button("Option B") { }
}''',
      'compose': '''AlertDialog(
  title = { Text("Choose") },
  text = {
    Column {
      TextButton({ }) { Text("Option A") }
      TextButton({ }) { Text("Option B") }
    }
  }
)''',
      'react': '''<Dialog open={open}>
  <DialogTitle>Choose</DialogTitle>
  <List>
    <ListItem button onClick={() => {}}>Option A</ListItem>
    <ListItem button onClick={() => {}}>Option B</ListItem>
  </List>
</Dialog>''',
    },
    'dialogs.confirm': {
      'flutter': '''showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Do you want to continue?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Confirm')),
    ],
  ),
);''',
      'swiftui': '''.confirmationDialog("Confirm", isPresented: \$showing) {
  Button("Cancel", role: .cancel) { }
  Button("Confirm") { }
} message: {
  Text("Do you want to continue?")
}''',
      'compose': '''AlertDialog(
  title = { Text("Confirm") },
  text = { Text("Do you want to continue?") },
  onDismissRequest = { },
  dismissButton = { TextButton({ }) { Text("Cancel") } },
  confirmButton = { Button({ }) { Text("Confirm") } }
)''',
      'react': '''<Dialog open={open}>
  <DialogTitle>Confirm</DialogTitle>
  <DialogContent>Do you want to continue?</DialogContent>
  <DialogActions>
    <Button onClick={() => setOpen(false)}>Cancel</Button>
    <Button variant="contained" onClick={onConfirm}>Confirm</Button>
  </DialogActions>
</Dialog>''',
    },
    'dialogs.bottomsheet': {
      'flutter': '''showModalBottomSheet(
  context: context,
  builder: (ctx) => Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Bottom sheet content'),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: Text('Close')),
      ],
    ),
  ),
);''',
      'swiftui': '''.sheet(isPresented: \$showing) {
  VStack {
    Text("Bottom sheet content")
    Button("Close") { showing = false }
  }
  .padding()
}''',
      'compose': '''ModalBottomSheet(
  onDismissRequest = { }
) {
  Column(Modifier.padding(24.dp)) {
    Text("Bottom sheet content")
    Button({ }) { Text("Close") }
  }
}''',
      'react': '''<Drawer anchor="bottom" open={open} onClose={() => setOpen(false)}>
  <Box p={2}>
    <Typography>Bottom sheet content</Typography>
    <Button onClick={() => setOpen(false)}>Close</Button>
  </Box>
</Drawer>''',
    },
    'tabs.tabbar': {
      'flutter': '''DefaultTabController(
  length: 3,
  child: Column(
    children: [
      TabBar(tabs: [
        Tab(text: 'One'),
        Tab(text: 'Two'),
        Tab(text: 'Three'),
      ]),
      Expanded(
        child: TabBarView(children: [
          Center(child: Text('Content 1')),
          Center(child: Text('Content 2')),
          Center(child: Text('Content 3')),
        ]),
      ),
    ],
  ),
)''',
      'swiftui': '''TabView(selection: \$selection) {
  Text("Content 1").tag(0)
  Text("Content 2").tag(1)
  Text("Content 3").tag(2)
}
.tabViewStyle(.page(indexDisplayMode: .never))
safeAreaInset(edge: .top, spacing: 0) {
  Picker("", selection: \$selection) {
    Text("One").tag(0)
    Text("Two").tag(1)
    Text("Three").tag(2)
  }
  .pickerStyle(.segmented)
}''',
      'compose': '''TabRow(selectedTabIndex = index) {
  Tab(text = "One")
  Tab(text = "Two")
  Tab(text = "Three")
}
TabRowDefaults.Indicator(...)
TabRowDefaults.Divider(...)
TabRow(selectedTabIndex = index) { ... }
HorizontalPager(state = pagerState) { page ->
  Text("Content \${page + 1}")
}''',
      'react': '''<Tabs value={value} onChange={(e, v) => setValue(v)}>
  <Tab label="One" />
  <Tab label="Two" />
  <Tab label="Three" />
</Tabs>
<TabPanel value={value} index={0}>Content 1</TabPanel>
<TabPanel value={value} index={1}>Content 2</TabPanel>
<TabPanel value={value} index={2}>Content 3</TabPanel>''',
    },
    'tabs.tabbaricons': {
      'flutter': '''TabBar(
  tabs: [
    Tab(icon: Icon(Icons.home), text: 'Home'),
    Tab(icon: Icon(Icons.star), text: 'Star'),
    Tab(icon: Icon(Icons.person), text: 'Profile'),
  ],
)''',
      'swiftui': '''Picker(selection: \$selection) {
  Label("Home", systemImage: "house").tag(0)
  Label("Star", systemImage: "star").tag(1)
  Label("Profile", systemImage: "person").tag(2)
}
.pickerStyle(.segmented)''',
      'compose': '''TabRow {
  Tab(icon = { Icon(Icons.Default.Home, null) }, text = { Text("Home") })
  Tab(icon = { Icon(Icons.Default.Star, null) }, text = { Text("Star") })
}''',
      'react': '''<Tabs value={value}>
  <Tab icon={<HomeIcon />} label="Home" />
  <Tab icon={<StarIcon />} label="Star" />
  <Tab icon={<PersonIcon />} label="Profile" />
</Tabs>''',
    },
    'tabs.scrollable': {
      'flutter': '''TabBar(
  isScrollable: true,
  tabAlignment: TabAlignment.start,
  tabs: [
    Tab(text: 'Tab A'),
    Tab(text: 'Tab B'),
    Tab(text: 'Tab C'),
  ],
)''',
      'swiftui': '''ScrollView(.horizontal) {
  HStack {
    ForEach(0..<5) { i in
      Button("Tab \\(i)") { \$selection = i }
        .buttonStyle(\$selection == i ? .borderedProminent : .bordered)
    }
  }
}''',
      'compose': '''ScrollableTabRow(
  selectedTabIndex = index,
  edgePadding = 0.dp
) {
  repeat(5) { i ->
    Tab(text = "Tab \$i")
  }
}''',
      'react': '''<Tabs value={value} variant="scrollable" scrollButtons="auto">
  <Tab label="Tab A" />
  <Tab label="Tab B" />
  <Tab label="Tab C" />
</Tabs>''',
    },
    'dropdowns.dropdown': {
      'flutter': '''DropdownButtonFormField<String>(
  value: 'option1',
  decoration: InputDecoration(
    labelText: 'Choose',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  items: [
    DropdownMenuItem(value: 'option1', child: Text('Option 1')),
    DropdownMenuItem(value: 'option2', child: Text('Option 2')),
  ],
  onChanged: (value) {},
)''',
      'swiftui': '''Menu("Choose") {
  Button("Option 1") { }
  Button("Option 2") { }
}
// or Picker with .menu style''',
      'compose': '''ExposedDropdownMenuBox(
  expanded = expanded,
  onExpandedChange = { expanded = it }
) {
  OutlinedTextField(
    value = value,
    readOnly = true,
    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) }
  )
  ExposedDropdownMenu(
    expanded = expanded,
    onDismissRequest = { expanded = false }
  ) {
    DropdownMenuItem({ value = "option1"; expanded = false }, { Text("Option 1") })
    DropdownMenuItem({ value = "option2"; expanded = false }, { Text("Option 2") })
  }
}''',
      'react': '''<FormControl fullWidth>
  <InputLabel>Choose</InputLabel>
  <Select value={value} label="Choose" onChange={(e) => setValue(e.target.value)}>
    <MenuItem value="option1">Option 1</MenuItem>
    <MenuItem value="option2">Option 2</MenuItem>
  </Select>
</FormControl>''',
    },
    'dropdowns.dropdownform': {
      'flutter': '''DropdownButtonFormField<String>(
  value: selected,
  decoration: InputDecoration(labelText: 'Select', border: OutlineInputBorder()),
  items: [DropdownMenuItem(value: 'a', child: Text('A')), ...],
  onChanged: (v) => setState(() => selected = v),
)''',
      'swiftui': '''Picker("Select", selection: \$selection) {
  Text("A").tag("a")
  Text("B").tag("b")
}
.pickerStyle(.menu)''',
      'compose': '''var value by remember { mutableStateOf("a") }
ExposedDropdownMenuBox(...) {
  OutlinedTextField(value = value, readOnly = true, ...)
  ExposedDropdownMenu(...) {
    DropdownMenuItem(..., { value = "a"; ... }, { Text("A") })
  }
}''',
      'react': '''<TextField select label="Select" value={value} onChange={(e) => setValue(e.target.value)}>
  <MenuItem value="a">A</MenuItem>
  <MenuItem value="b">B</MenuItem>
</TextField>''',
    },
    'dropdowns.popupmenu': {
      'flutter': '''PopupMenuButton<String>(
  onSelected: (value) {},
  itemBuilder: (ctx) => [
    PopupMenuItem(value: 'edit', child: Text('Edit')),
    PopupMenuItem(value: 'delete', child: Text('Delete')),
  ],
  child: ListTile(title: Text('Tap for menu'), trailing: Icon(Icons.arrow_drop_down)),
)''',
      'swiftui': '''Menu {
  Button("Edit") { }
  Button("Delete", role: .destructive) { }
} label: {
  Label("Tap for menu", systemImage: "chevron.down")
}''',
      'compose': '''DropdownMenu(
  expanded = expanded,
  onDismissRequest = { expanded = false }
) {
  DropdownMenuItem({ }, { Text("Edit") })
  DropdownMenuItem({ }, { Text("Delete") })
}''',
      'react': '''<Menu anchorEl={anchorEl} open={open} onClose={() => setAnchorEl(null)}>
  <MenuItem onClick={() => {}}>Edit</MenuItem>
  <MenuItem onClick={() => {}}>Delete</MenuItem>
</Menu>
<Button onClick={(e) => setAnchorEl(e.currentTarget)}>Tap for menu</Button>''',
    },
    'dropdowns.menuanchor': {
      'flutter': '''MenuAnchor(
  builder: (ctx, controller, child) => ElevatedButton(
    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
    child: Text('Open menu'),
  ),
  menuChildren: [
    MenuItemButton(onPressed: () {}, child: Text('Item 1')),
    MenuItemButton(onPressed: () {}, child: Text('Item 2')),
  ],
)''',
      'swiftui': '''Menu { ... } label: { Text("Open menu") }''',
      'compose': '''DropdownMenuBox(...) {
  Button({ expanded = true }) { Text("Open menu") }
  DropdownMenu(...) { MenuItem(...) }
}''',
      'react': '''<Button onClick={(e) => setAnchorEl(e.currentTarget)}>Open menu</Button>
<Menu anchorEl={anchorEl} open={open} onClose={() => setAnchorEl(null)}>
  <MenuItem>Item 1</MenuItem>
  <MenuItem>Item 2</MenuItem>
</Menu>''',
    },
    'tables.simple': {
      'flutter': '''Table(
  children: [
    TableRow(children: [Padding(padding: EdgeInsets.all(8), child: Text('A1')), Text('A2')]),
    TableRow(children: [Padding(padding: EdgeInsets.all(8), child: Text('B1')), Text('B2')]),
  ],
)''',
      'swiftui': '''Table {
  TableRow {
    Text("A1")
    Text("A2")
  }
  TableRow {
    Text("B1")
    Text("B2")
  }
}''',
      'compose': '''Table(
  modifier = Modifier.fillMaxWidth()
) {
  tableRow {
    tableCell { Text("A1") }
    tableCell { Text("A2") }
  }
  tableRow {
    tableCell { Text("B1") }
    tableCell { Text("B2") }
  }
}''',
      'react': '''<Table>
  <TableBody>
    <TableRow><TableCell>A1</TableCell><TableCell>A2</TableCell></TableRow>
    <TableRow><TableCell>B1</TableCell><TableCell>B2</TableCell></TableRow>
  </TableBody>
</Table>''',
    },
    'tables.bordered': {
      'flutter': '''Table(
  border: TableBorder.all(color: Colors.grey),
  children: [
    TableRow(decoration: BoxDecoration(color: Colors.grey.shade200), children: [padding('H1'), padding('H2')]),
    TableRow(children: [padding('C1'), padding('C2')]),
  ],
)''',
      'swiftui': '''Table { ... }.border(.gray)''',
      'compose': '''Table(border = TableDefaults.outlinedTableBorder()) { ... }''',
      'react': '''<Table sx={{ border: '1px solid', borderColor: 'grey.300' }}>
  <TableHead><TableRow><TableCell>H1</TableCell><TableCell>H2</TableCell></TableRow></TableHead>
  <TableBody><TableRow><TableCell>C1</TableCell><TableCell>C2</TableCell></TableRow></TableBody>
</Table>''',
    },
    'lists.listtile': {
      'flutter': '''ListTile(
  leading: Icon(Icons.star),
  title: Text('List tile'),
  onTap: () {},
)
ListTile(
  leading: Icon(Icons.favorite),
  title: Text('Another'),
  subtitle: Text('Subtitle'),
  onTap: () {},
)''',
      'swiftui': '''List {
  Label("List tile", systemImage: "star")
  Label("Another", systemImage: "heart")
    .badge(Text("Subtitle"))
}''',
      'compose': '''ListItem(
  headlineContent = { Text("List tile") },
  leadingContent = { Icon(Icons.Default.Star, null) },
  modifier = Modifier.clickable { }
)
ListItem(
  headlineContent = { Text("Another") },
  supportingContent = { Text("Subtitle") },
  leadingContent = { Icon(Icons.Default.Favorite, null) }
)''',
      'react': '''<List>
  <ListItem button><ListItemIcon><StarIcon /></ListItemIcon><ListItemText primary="List tile" /></ListItem>
  <ListItem button><ListItemIcon><FavoriteIcon /></ListItemIcon><ListItemText primary="Another" secondary="Subtitle" /></ListItem>
</List>''',
    },
    'lists.dividers': {
      'flutter': '''Column(
  children: [
    ListTile(title: Text('Item 1'), onTap: () {}),
    Divider(height: 1),
    ListTile(title: Text('Item 2'), onTap: () {}),
  ],
)''',
      'swiftui': '''List { ... }.listStyle(.insetGrouped)''',
      'compose': '''Column {
  ListItem(...)
  HorizontalDivider()
  ListItem(...)
}''',
      'react': '''<List>
  <ListItem><ListItemText primary="Item 1" /></ListItem>
  <Divider />
  <ListItem><ListItemText primary="Item 2" /></ListItem>
</List>''',
    },
    'lists.sections': {
      'flutter': '''Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(padding: EdgeInsets.all(16), child: Text('Section A', style: Theme.of(context).textTheme.titleSmall)),
    ListTile(title: Text('A1'), onTap: () {}),
    ListTile(title: Text('A2'), onTap: () {}),
    Padding(padding: EdgeInsets.all(16), child: Text('Section B', style: Theme.of(context).textTheme.titleSmall)),
    ListTile(title: Text('B1'), onTap: () {}),
  ],
)''',
      'swiftui': '''List {
  Section("Section A") {
    Label("A1", systemImage: "circle")
    Label("A2", systemImage: "circle")
  }
  Section("Section B") {
    Label("B1", systemImage: "circle")
  }
}''',
      'compose': '''LazyColumn {
  item {
    Text("Section A", style = MaterialTheme.typography.titleSmall)
    Spacer(Modifier.height(8.dp))
  }
  items(aItems) { ListItem(...) }
  item {
    Text("Section B", ...)
  }
  items(bItems) { ListItem(...) }
}''',
      'react': '''<List subheader={<ListSubheader>Section A</ListSubheader>}>
  <ListItem>A1</ListItem>
  <ListItem>A2</ListItem>
</List>
<List subheader={<ListSubheader>Section B</ListSubheader>}>
  <ListItem>B1</ListItem>
</List>''',
    },
    'lists.dismissible': {
      'flutter': '''Dismissible(
  key: ValueKey(item.id),
  background: Container(color: Colors.red, alignment: Alignment.centerLeft, child: Icon(Icons.delete, color: Colors.white)),
  direction: DismissDirection.endToStart,
  onDismissed: (direction) => setState(() => items.remove(item)),
  child: ListTile(title: Text(item.name)),
)''',
      'swiftui': '''List(\$items) { item in
  Text(item.name)
    .swipeActions(edge: .trailing) {
      Button(role: .destructive) { delete(item) } label: { Label("Delete", systemImage: "trash") }
    }
}''',
      'compose': '''SwipeToDismissBox(
  state = rememberSwipeToDismissBoxState(confirmValueChange = { it != DismissValue.Default }),
  backgroundContent = { Box(Modifier.fillMaxSize().background(Color.Red)) },
  enableDismissFromStartToEnd = false
) {
  ListItem(headlineContent = { Text(item.name) })
}''',
      'react': '''<SwipeableListItem
  onSwipe={() => removeItem(item)}
  rightAction={<IconButton onClick={() => removeItem(item)}><DeleteIcon /></IconButton>}
>
  <ListItemText primary={item.name} />
</SwipeableListItem>''',
    },
    'form.switch': {
      'flutter': '''SwitchListTile(
  title: Text('Enable notifications'),
  value: value,
  onChanged: (v) => setState(() => value = v),
)''',
      'swiftui': '''Toggle("Enable notifications", isOn: \$value)''',
      'compose': '''Switch(
  checked = value,
  onCheckedChange = { value = it }
)
Row(verticalAlignment = Alignment.CenterVertically) {
  Text("Enable notifications")
  Spacer(Modifier.weight(1f))
  Switch(checked = value, onCheckedChange = { value = it })
}''',
      'react': '''<FormControlLabel
  control={<Switch checked={value} onChange={(e) => setValue(e.target.checked)} />}
  label="Enable notifications"
/>''',
    },
    'form.checkbox': {
      'flutter': '''CheckboxListTile(
  title: Text('I agree to the terms'),
  value: checked,
  onChanged: (v) => setState(() => checked = v ?? false),
)''',
      'swiftui': '''Toggle("I agree to the terms", isOn: \$checked)''',
      'compose': '''Checkbox(
  checked = checked,
  onCheckedChange = { checked = it }
)
Row(verticalAlignment = Alignment.CenterVertically) {
  Checkbox(checked = checked, onCheckedChange = { checked = it })
  Text("I agree to the terms")
}''',
      'react': '''<FormControlLabel
  control={<Checkbox checked={checked} onChange={(e) => setChecked(e.target.checked)} />}
  label="I agree to the terms"
/>''',
    },
    'form.radio': {
      'flutter': '''RadioListTile<String>(
  title: Text('Option A'),
  value: 'a',
  groupValue: value,
  onChanged: (v) => setState(() => value = v!),
)
RadioListTile<String>(
  title: Text('Option B'),
  value: 'b',
  groupValue: value,
  onChanged: (v) => setState(() => value = v!),
)''',
      'swiftui': '''Picker("", selection: \$value) {
  Text("Option A").tag("a")
  Text("Option B").tag("b")
}
.pickerStyle(.radioGroup)''',
      'compose': '''RadioButtonGroup(
  value = value,
  onValueChange = { value = it }
) {
  Row {
    RadioButton(selected = value == "a", onClick = { value = "a" })
    Text("Option A")
  }
  Row {
    RadioButton(selected = value == "b", onClick = { value = "b" })
    Text("Option B")
  }
}''',
      'react': '''<RadioGroup value={value} onChange={(e) => setValue(e.target.value)}>
  <FormControlLabel value="a" control={<Radio />} label="Option A" />
  <FormControlLabel value="b" control={<Radio />} label="Option B" />
</RadioGroup>''',
    },
    'form.slider': {
      'flutter': '''Slider(
  value: value,
  onChanged: (v) => setState(() => value = v),
)
Text('Value: \${(value * 100).round()}%')''',
      'swiftui': '''VStack {
  Slider(value: \$value, in: 0...1)
  Text("\\(value * 100, specifier: "%.0f")%")
}''',
      'compose': '''Slider(
  value = value,
  onValueChange = { value = it },
  valueRange = 0f..1f
)
Text("Value: \${(value * 100).toInt()}%")''',
      'react': '''<Slider value={value} onChange={(e, v) => setValue(v)} valueLabelDisplay="auto" />
<Typography>Value: {Math.round(value * 100)}%</Typography>''',
    },
    'feedback.chip': {
      'flutter': '''Chip(label: Text('Default'))
Chip(
  avatar: CircleAvatar(child: Icon(Icons.person, size: 18)),
  label: Text('With avatar'),
)
InputChip(label: Text('Deletable'), onDeleted: () {})
FilterChip(label: Text('Filter'), selected: false, onSelected: (_) {})
ActionChip(label: Text('Action'), onPressed: () {})''',
      'swiftui': '''Label("Default", systemImage: "tag")
// or custom view with .chipStyle()''',
      'compose': '''Chip(onClick = { }, label = { Text("Default") })
Chip(
  onClick = { },
  label = { Text("With avatar") },
  leadingIcon = { Icon(Icons.Default.Person, null) }
)
Chip(onClick = { }, label = { Text("Deletable") }, trailingIcon = { Icon(Icons.Default.Close, null) })''',
      'react': '''<Chip label="Default" />
<Chip label="With avatar" avatar={<Avatar />} />
<Chip label="Deletable" onDelete={() => {}} />
<Chip label="Filter" variant="outlined" onClick={() => {}} />
<Chip label="Action" onClick={() => {}} />''',
    },
    'feedback.snackbar': {
      'flutter': '''ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    action: SnackBarAction(label: 'Undo', onPressed: () {}),
  ),
);''',
      'swiftui': '''// Use .overlay or custom toast''',
      'compose': '''SnackbarHost(hostState) { data ->
  Snackbar(
    action = { TextButton({ }) { Text("Undo") } },
    modifier = Modifier...
  ) { Text(data.visuals.message) }
}
scope.launch {
  hostState.showSnackbar("Message", actionLabel = "Undo")
}''',
      'react': '''<Snackbar open={open} autoHideDuration={6000} onClose={() => setOpen(false)}
  message="Message" action={<Button onClick={() => {}}>Undo</Button>} />''',
    },
    'feedback.linear': {
      'flutter': '''LinearProgressIndicator()
LinearProgressIndicator(
  value: 0.6,
  backgroundColor: Colors.grey.shade200,
)''',
      'swiftui': '''ProgressView(value: 0.6)
ProgressView() // indeterminate''',
      'compose': '''LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
LinearProgressIndicator(
  progress = 0.6f,
  modifier = Modifier.fillMaxWidth()
)''',
      'react': '''<LinearProgress />
<LinearProgress variant="determinate" value={60} />''',
    },
    'feedback.circular': {
      'flutter': '''CircularProgressIndicator()
SizedBox(
  width: 48, height: 48,
  child: CircularProgressIndicator(value: 0.7, strokeWidth: 4),
)''',
      'swiftui': '''ProgressView().scale(2)''',
      'compose': '''CircularProgressIndicator(modifier = Modifier.size(48.dp))
CircularProgressIndicator(progress = 0.7f, modifier = Modifier.size(48.dp), strokeWidth = 4.dp)''',
      'react': '''<CircularProgress />
<CircularProgress variant="determinate" value={70} size={48} />''',
    },
    'charts.bar': {
      'flutter': '''// Using fl_chart
BarChart(
  BarChartData(
    alignment: BarChartAlignment.spaceAround,
    maxY: 10,
    barGroups: [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4, color: Colors.blue, width: 16)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: Colors.green, width: 16)]),
    ],
  ),
)''',
      'swiftui': '''Chart {
  BarMark(x: .value("x", 0), y: .value("y", 4))
  BarMark(x: .value("x", 1), y: .value("y", 7))
}''',
      'compose': '''// Using Vico or Compose Charts
BarChart(
  chart = barChart { ... },
  modifier = Modifier.height(200.dp)
)''',
      'react': '''// Using recharts or MUI X
<BarChart data={data}>
  <Bar dataKey="y" fill="#1976d2" />
  <XAxis dataKey="x" />
  <YAxis />
</BarChart>''',
    },
    'charts.line': {
      'flutter': '''LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 3)],
        isCurved: true,
        color: Theme.of(context).colorScheme.primary,
      ),
    ],
  ),
)''',
      'swiftui': '''Chart {
  LineMark(x: .value("x", 0), y: .value("y", 2))
  LineMark(x: .value("x", 1), y: .value("y", 4))
}''',
      'compose': '''LineChart(data = lineData, modifier = Modifier.height(200.dp))''',
      'react': '''<LineChart data={data}>
  <Line type="monotone" dataKey="y" stroke="#1976d2" />
  <XAxis dataKey="x" />
  <YAxis />
</LineChart>''',
    },
    'charts.pie': {
      'flutter': '''PieChart(
  PieChartData(
    sectionsSpace: 2,
    centerSpaceRadius: 40,
    sections: [
      PieChartSectionData(value: 40, color: Colors.blue, title: '40%'),
      PieChartSectionData(value: 30, color: Colors.green, title: '30%'),
      PieChartSectionData(value: 30, color: Colors.orange, title: '30%'),
    ],
  ),
)''',
      'swiftui': '''Chart {
  SectorMark(angle: .value("angle", 144), innerRadius: .ratio(0.5), color: .blue)
  SectorMark(angle: .value("angle", 108), innerRadius: .ratio(0.5), color: .green)
}''',
      'compose': '''PieChart(chart = pieChart { ... }, modifier = Modifier.size(200.dp))''',
      'react': '''<PieChart>
  <Pie data={data} dataKey="value" nameKey="name" cx="50%" cy="50%" />
</PieChart>''',
    },
    'datatables.datatable': {
      'flutter': '''DataTable(
  columns: [
    DataColumn(label: Text('Name')),
    DataColumn(label: Text('Role')),
  ],
  rows: [
    DataRow(cells: [DataCell(Text('Alice')), DataCell(Text('Admin'))]),
    DataRow(cells: [DataCell(Text('Bob')), DataCell(Text('User'))]),
  ],
)''',
      'swiftui': '''Table { ... }''',
      'compose': '''DataTable(
  columns = listOf(
    TableColumn("Name"),
    TableColumn("Role")
  ),
  rows = listOf(
    TableRow(cells = listOf(TableCell(Text("Alice")), TableCell(Text("Admin")))),
    TableRow(cells = listOf(TableCell(Text("Bob")), TableCell(Text("User"))))
  )
)''',
      'react': '''<Table>
  <TableHead>
    <TableRow><TableCell>Name</TableCell><TableCell>Role</TableCell></TableRow>
  </TableHead>
  <TableBody>
    <TableRow><TableCell>Alice</TableCell><TableCell>Admin</TableCell></TableRow>
    <TableRow><TableCell>Bob</TableCell><TableCell>User</TableCell></TableRow>
  </TableBody>
</Table>''',
    },
    'datatables.sortable': {
      'flutter': '''DataTable(
  sortColumnIndex: sortCol,
  sortAscending: sortAsc,
  columns: [
    DataColumn(label: Text('Name'), onSort: (_, asc) => setState(() { sortCol = 0; sortAsc = asc; })),
    DataColumn(label: Text('Role'), onSort: (_, asc) => setState(() { sortCol = 1; sortAsc = asc; })),
  ],
  rows: sortedRows,
)''',
      'swiftui': '''Table(selection: \$selection, sortOrder: \$sortOrder) {
  TableColumn("Name", value: \\.name)
  TableColumn("Role", value: \\.role)
}
.rows(rows)''',
      'compose': '''DataTable(
  columns = ...,
  sortOrder = sortOrder,
  onSortRequest = { sortOrder = it }
)''',
      'react': '''<TableSortLabel active={orderBy === 'name'} direction={order} onClick={() => handleSort('name')}>
  Name
</TableSortLabel>''',
    },
    'dashboards.summary': {
      'flutter': '''Row(
  children: [
    Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Revenue', style: Theme.of(context).textTheme.labelMedium), Text('\$12.4k', style: Theme.of(context).textTheme.titleLarge)])))),
    SizedBox(width: 12),
    Expanded(child: Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Users', style: Theme.of(context).textTheme.labelMedium), Text('1,234', style: Theme.of(context).textTheme.titleLarge)])))),
  ],
)''',
      'swiftui': '''HStack {
  VStack(alignment: .leading) { Text("Revenue").font(.caption); Text("\$12.4k").font(.title2) }
    .frame(maxWidth: .infinity).padding()
  VStack(alignment: .leading) { Text("Users").font(.caption); Text("1,234").font(.title2) }
    .frame(maxWidth: .infinity).padding()
}''',
      'compose': '''Row(Modifier.fillMaxWidth()) {
  Card(Modifier.weight(1f)) {
    Column(Modifier.padding(16.dp)) {
      Text("Revenue", style = MaterialTheme.typography.labelMedium)
      Text("\$12.4k", style = MaterialTheme.typography.titleLarge)
    }
  }
  Spacer(Modifier.width(12.dp))
  Card(Modifier.weight(1f)) { ... }
}''',
      'react': '''<Grid container spacing={2}>
  <Grid item xs={6}><Card><CardContent><Typography color="textSecondary">Revenue</Typography><Typography variant="h5">\$12.4k</Typography></CardContent></Card></Grid>
  <Grid item xs={6}><Card><CardContent><Typography color="textSecondary">Users</Typography><Typography variant="h5">1,234</Typography></CardContent></Card></Grid>
</Grid>''',
    },
    'dashboards.metrics': {
      'flutter': '''GridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  children: [
    Card(child: Padding(padding: EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people), Text('42'), Text('Active')]))),
    // ...
  ],
)''',
      'swiftui': '''LazyVGrid(columns: [GridItem(), GridItem()]) {
  ForEach(metrics) { m in
    VStack { Image(systemName: m.icon); Text(m.value); Text(m.label) }
      .frame(maxWidth: .infinity).padding()
  }
}''',
      'compose': '''LazyVerticalGrid(columns = GridCells.Fixed(2)) {
  items(metrics) { m ->
    Card {
      Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(m.icon, null)
        Text(m.value)
        Text(m.label)
      }
    }
  }
}''',
      'react': '''<Grid container spacing={2}>
  {metrics.map(m => (
    <Grid item xs={6} key={m.label}>
      <Card><CardContent><Typography>{m.value}</Typography><Typography variant="caption">{m.label}</Typography></CardContent></Card>
    </Grid>
  ))}
</Grid>''',
    },
    'dashboards.activity': {
      'flutter': '''Column(
  children: [
    ListTile(leading: CircleAvatar(child: Icon(Icons.person_add)), title: Text('New user signed up'), subtitle: Text('2 min ago')),
    ListTile(leading: CircleAvatar(child: Icon(Icons.check_circle)), title: Text('Order #1234 completed'), subtitle: Text('1 hour ago')),
  ],
)''',
      'swiftui': '''List(activities) { a in
  HStack {
    Image(systemName: a.icon)
    VStack(alignment: .leading) {
      Text(a.title)
      Text(a.time).font(.caption).foregroundStyle(.secondary)
    }
  }
}''',
      'compose': '''LazyColumn {
  items(activities) { a ->
    ListItem(
      leadingContent = { Icon(a.icon, null) },
      headlineContent = { Text(a.title) },
      supportingContent = { Text(a.time) }
    )
  }
}''',
      'react': '''<List>
  {activities.map(a => (
    <ListItem key={a.id}>
      <ListItemAvatar><Avatar><Icon>{a.icon}</Icon></Avatar></ListItemAvatar>
      <ListItemText primary={a.title} secondary={a.time} />
    </ListItem>
  ))}
</List>''',
    },
  };
}
