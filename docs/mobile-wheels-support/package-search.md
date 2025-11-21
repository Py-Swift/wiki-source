# Package Database Search

Search through 700,000+ Python packages to check iOS and Android mobile platform support.

<div class="tabs">
  <input type="radio" id="tab-search" name="tabs" checked>
  <label for="tab-search">Package Search</label>
  
  <input type="radio" id="tab-requirements" name="tabs">
  <label for="tab-requirements">Requirements Analysis</label>
  
  <div class="tab-content" id="content-search">
    <div class="search-container">
      <input 
        type="text" 
        id="package-search" 
        placeholder="Search package name (e.g., numpy, pandas, requests)..."
        autocomplete="off"
      />
      <div class="filter-options">
        <label>
          <input type="checkbox" id="filter-ios" checked> iOS Support
        </label>
        <label>
          <input type="checkbox" id="filter-android" checked> Android Support
        </label>
        <label>
          <input type="checkbox" id="filter-pure" checked> Pure Python
        </label>
        <label>
          <input type="checkbox" id="filter-binary" checked> Binary Only
        </label>
      </div>
    </div>

    <div id="search-stats" class="stats-bar">
      <span id="total-results">Ready to search 702,223 packages</span>
      <span id="search-time"></span>
    </div>

    <div id="results-container">
      <div class="instructions">
        <h3>🔍 How to use</h3>
        <ul>
          <li><strong>Type to search:</strong> Enter a package name (partial matches work)</li>
          <li><strong>Filter results:</strong> Use checkboxes to filter by platform support</li>
          <li><strong>View details:</strong> Click on a package to see version and source info</li>
        </ul>
        <p class="tip">💡 <strong>Tip:</strong> Search is case-insensitive and searches across all 702,223 packages in real-time.</p>
      </div>
    </div>
  </div>
  
  <div class="tab-content" id="content-requirements">
    <div class="requirements-container">
      <div class="upload-section">
        <h3>📋 Upload requirements.txt</h3>
        <div class="upload-area" id="upload-area">
          <input type="file" id="file-input" accept=".txt" style="display: none;">
          <label for="file-input" class="upload-label">
            <span class="upload-icon">📁</span>
            <span class="upload-text">Click to upload or drag & drop requirements.txt</span>
          </label>
        </div>
        <div class="or-divider">— OR —</div>
        <textarea 
          id="requirements-text" 
          placeholder="Paste your requirements here (one per line)&#10;numpy>=1.20.0&#10;pandas&#10;requests==2.28.0&#10;flask~=2.0.0"
          rows="10"
        ></textarea>
        <button id="analyze-btn" class="analyze-button">🔍 Analyze Requirements</button>
      </div>

      <div id="requirements-stats" class="stats-bar" style="display: none;">
        <span id="req-total">Total: 0</span>
        <span id="req-ios">iOS: 0</span>
        <span id="req-android">Android: 0</span>
        <span id="req-pure">Pure Python: 0</span>
        <span id="req-missing">Not Available: 0</span>
      </div>

      <div id="requirements-results"></div>
    </div>
  </div>
</div>

<style>
/* Tab Styles */
.tabs {
  margin: 20px 0;
}

.tabs input[type="radio"] {
  display: none;
}

.tabs label {
  display: inline-block;
  padding: 12px 24px;
  background: var(--md-code-bg-color);
  border: 2px solid var(--md-primary-fg-color);
  border-bottom: none;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
  margin-right: 4px;
  border-radius: 8px 8px 0 0;
}

.tabs label:hover {
  background: var(--md-primary-fg-color--light);
}

.tabs input[type="radio"]:checked + label {
  background: var(--md-primary-fg-color);
  color: white;
}

.tab-content {
  display: none;
  padding: 20px;
  border: 2px solid var(--md-primary-fg-color);
  border-radius: 0 8px 8px 8px;
  background: var(--md-default-bg-color);
  width: 100%;
  box-sizing: border-box;
}

#tab-search:checked ~ #content-search {
  display: block;
}

#tab-requirements:checked ~ #content-requirements {
  display: block;
}

/* Requirements Tab Styles */
.requirements-container {
  max-width: 100%;
  margin: 0 auto;
}

.upload-section {
  background: var(--md-code-bg-color);
  padding: 30px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.upload-section h3 {
  margin-top: 0;
  color: var(--md-primary-fg-color);
}

.upload-area {
  border: 3px dashed var(--md-primary-fg-color);
  border-radius: 8px;
  padding: 40px;
  text-align: center;
  background: var(--md-default-bg-color);
  transition: all 0.3s;
  cursor: pointer;
}

.upload-area:hover,
.upload-area.dragover {
  background: var(--md-primary-fg-color--light);
  border-color: var(--md-accent-fg-color);
}

.upload-label {
  cursor: pointer;
  display: block;
}

.upload-icon {
  font-size: 48px;
  display: block;
  margin-bottom: 10px;
}

.upload-text {
  font-size: 16px;
  color: var(--md-default-fg-color);
}

.or-divider {
  text-align: center;
  margin: 20px 0;
  color: var(--md-default-fg-color--light);
  font-weight: 600;
}

#requirements-text {
  width: 100%;
  padding: 12px;
  border: 2px solid var(--md-primary-fg-color);
  border-radius: 6px;
  font-family: var(--md-code-font-family);
  font-size: 14px;
  background: var(--md-default-bg-color);
  color: var(--md-default-fg-color);
  resize: vertical;
}

.analyze-button {
  width: 100%;
  padding: 14px;
  background: var(--md-primary-fg-color);
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 15px;
  transition: all 0.3s;
}

.analyze-button:hover {
  background: var(--md-accent-fg-color);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

.analyze-button:active {
  transform: translateY(0);
}

.requirements-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
  background: var(--md-default-bg-color);
  border-radius: 8px;
  overflow: hidden;
}

.requirements-table th {
  background: var(--md-primary-fg-color);
  color: white;
  padding: 12px;
  text-align: left;
  font-weight: 600;
}

.requirements-table td {
  padding: 12px;
  border-bottom: 1px solid var(--md-default-fg-color--lightest);
}

.requirements-table tr:hover {
  background: var(--md-code-bg-color);
}

.requirements-table tr:last-child td {
  border-bottom: none;
}

.req-status {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.version-spec {
  font-family: var(--md-code-font-family);
  color: var(--md-default-fg-color--light);
  font-size: 12px;
}

/* Original Search Styles */
.search-container {
  margin: 20px 0;
  background: var(--md-default-bg-color);
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  max-width: 100%;
}

#package-search {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
  border: 2px solid var(--md-primary-fg-color);
  border-radius: 6px;
  outline: none;
  transition: border-color 0.3s;
  background: var(--md-code-bg-color);
  color: var(--md-default-fg-color);
}

#package-search:focus {
  border-color: var(--md-accent-fg-color);
}

.filter-options {
  display: flex;
  gap: 20px;
  margin-top: 15px;
  flex-wrap: wrap;
}

.filter-options label {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  font-size: 14px;
}

.filter-options input[type="checkbox"] {
  cursor: pointer;
  width: 18px;
  height: 18px;
}

.stats-bar {
  display: flex;
  justify-content: space-between;
  padding: 12px 16px;
  background: var(--md-code-bg-color);
  border-radius: 6px;
  margin: 10px 0;
  font-size: 14px;
  color: var(--md-default-fg-color--light);
}

#results-container {
  margin-top: 20px;
}

.instructions {
  background: var(--md-code-bg-color);
  padding: 20px;
  border-radius: 8px;
  border-left: 4px solid var(--md-primary-fg-color);
}

.instructions h3 {
  margin-top: 0;
  color: var(--md-primary-fg-color);
}

.instructions ul {
  margin: 10px 0;
}

.instructions li {
  margin: 8px 0;
}

.tip {
  margin-top: 15px;
  padding: 10px;
  background: var(--md-default-bg-color);
  border-radius: 4px;
}

.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  background: var(--md-default-bg-color);
  border-radius: 8px;
  overflow: hidden;
}

.results-table th {
  background: var(--md-primary-fg-color);
  color: white;
  padding: 12px;
  text-align: left;
  font-weight: 600;
}

.results-table td {
  padding: 12px;
  border-bottom: 1px solid var(--md-default-fg-color--lightest);
}

.results-table tr:hover {
  background: var(--md-code-bg-color);
}

.results-table tr:last-child td {
  border-bottom: none;
}

.status-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}

.status-supported {
  background: #4caf50;
  color: white;
}

.status-not-available {
  background: #ff9800;
  color: white;
}

.status-pure-python {
  background: #2196f3;
  color: white;
}

.package-name {
  font-family: var(--md-code-font-family);
  font-weight: 600;
  color: var(--md-primary-fg-color);
}

.package-details {
  font-size: 12px;
  color: var(--md-default-fg-color--light);
  margin-top: 4px;
}

.loading {
  text-align: center;
  padding: 40px;
  color: var(--md-default-fg-color--light);
}

.no-results {
  text-align: center;
  padding: 40px;
  color: var(--md-default-fg-color--light);
  font-size: 16px;
}

.pagination {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin: 20px 0;
  flex-wrap: wrap;
}

.pagination button {
  padding: 8px 16px;
  border: 1px solid var(--md-primary-fg-color);
  background: var(--md-default-bg-color);
  color: var(--md-primary-fg-color);
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s;
}

.pagination button:hover:not(:disabled) {
  background: var(--md-primary-fg-color);
  color: white;
}

.pagination button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination button.active {
  background: var(--md-primary-fg-color);
  color: white;
}
</style>

<script>
(function() {
  const INDEX_URL = '../json-chunks/index.json';
  const CHUNK_BASE_URL = '../json-chunks/';
  const RESULTS_PER_PAGE = 50;
  
  let indexData = null;
  let currentResults = [];
  let currentPage = 1;
  
  // Cache for loaded chunks
  const chunkCache = new Map();
  
  // Get filter state
  function getFilters() {
    return {
      ios: document.getElementById('filter-ios').checked,
      android: document.getElementById('filter-android').checked,
      pure: document.getElementById('filter-pure').checked,
      binary: document.getElementById('filter-binary').checked
    };
  }
  
  // Load index.json
  async function loadIndex() {
    try {
      const response = await fetch(INDEX_URL);
      indexData = await response.json();
      console.log(`Loaded index: ${indexData.total_chunks} chunks, ${indexData.total_packages} packages`);
    } catch (error) {
      console.error('Error loading index:', error);
      showError('Failed to load package index');
    }
  }
  
  // Load a specific chunk
  async function loadChunk(filename) {
    if (chunkCache.has(filename)) {
      return chunkCache.get(filename);
    }
    
    try {
      const response = await fetch(CHUNK_BASE_URL + filename);
      const data = await response.json();
      chunkCache.set(filename, data);
      return data;
    } catch (error) {
      console.error(`Error loading chunk ${filename}:`, error);
      return [];
    }
  }
  
  // Search across all chunks
  async function searchPackages(query) {
    if (!indexData || !query || query.length < 2) {
      return [];
    }
    
    const startTime = performance.now();
    const searchTerm = query.toLowerCase().trim();
    const results = [];
    const filters = getFilters();
    
    // Search through all chunks
    for (const chunk of indexData.chunks) {
      const packages = await loadChunk(chunk.filename);
      
      for (const pkg of packages) {
        if (pkg.name.toLowerCase().includes(searchTerm)) {
          // Apply filters
          if (!matchesFilters(pkg, filters)) continue;
          
          results.push(pkg);
          
          // Limit results to prevent browser from hanging
          if (results.length >= 500) {
            break;
          }
        }
      }
      
      if (results.length >= 500) break;
    }
    
    const endTime = performance.now();
    const searchTime = ((endTime - startTime) / 1000).toFixed(2);
    
    document.getElementById('search-time').textContent = 
      `Search completed in ${searchTime}s`;
    
    return results;
  }
  
  // Check if package matches filters
  function matchesFilters(pkg, filters) {
    const hasIOS = pkg.ios === 'supported';
    const hasAndroid = pkg.android === 'supported';
    const isPure = pkg.ios === 'pure_python' || pkg.android === 'pure_python';
    const isBinary = pkg.category === 'official_binary' || pkg.category === 'pyswift_binary';
    
    if (!filters.ios && hasIOS && !isPure) return false;
    if (!filters.android && hasAndroid && !isPure) return false;
    if (!filters.pure && isPure) return false;
    if (!filters.binary && isBinary && !isPure) return false;
    
    return true;
  }
  
  // Format status badge
  function formatStatus(status, version) {
    if (status === 'supported') {
      const versionText = version ? ` (${version})` : '';
      return `<span class="status-badge status-supported">✅ Supported${versionText}</span>`;
    } else if (status === 'pure_python') {
      return `<span class="status-badge status-pure-python">🐍 Pure Python</span>`;
    } else {
      return `<span class="status-badge status-not-available">⚠️ Not available</span>`;
    }
  }
  
  // Get category display name
  function getCategoryName(category) {
    const categories = {
      'official_binary': 'Official Binary (PyPI)',
      'pyswift_binary': 'PySwift Binary',
      'pure_python': 'Pure Python',
      'binary_without_mobile': 'Binary (No Mobile)'
    };
    return categories[category] || category;
  }
  
  // Display results
  function displayResults(page = 1) {
    const container = document.getElementById('results-container');
    const totalResults = currentResults.length;
    
    if (totalResults === 0) {
      container.innerHTML = '<div class="no-results">No packages found matching your search criteria.</div>';
      return;
    }
    
    const start = (page - 1) * RESULTS_PER_PAGE;
    const end = Math.min(start + RESULTS_PER_PAGE, totalResults);
    const pageResults = currentResults.slice(start, end);
    
    let html = `
      <table class="results-table">
        <thead>
          <tr>
            <th>Package</th>
            <th>iOS</th>
            <th>Android</th>
            <th>Category</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    for (const pkg of pageResults) {
      html += `
        <tr>
          <td>
            <div class="package-name">${pkg.name}</div>
            <div class="package-details">Source: ${pkg.source || 'Unknown'}</div>
          </td>
          <td>${formatStatus(pkg.ios, pkg.iosVersion)}</td>
          <td>${formatStatus(pkg.android, pkg.androidVersion)}</td>
          <td>${getCategoryName(pkg.category)}</td>
        </tr>
      `;
    }
    
    html += '</tbody></table>';
    
    // Add pagination
    const totalPages = Math.ceil(totalResults / RESULTS_PER_PAGE);
    if (totalPages > 1) {
      html += '<div class="pagination">';
      
      if (page > 1) {
        html += `<button onclick="goToPage(${page - 1})">← Previous</button>`;
      }
      
      // Show page numbers (with ellipsis for many pages)
      const pageNumbers = [];
      if (totalPages <= 7) {
        for (let i = 1; i <= totalPages; i++) pageNumbers.push(i);
      } else {
        pageNumbers.push(1);
        if (page > 3) pageNumbers.push('...');
        for (let i = Math.max(2, page - 1); i <= Math.min(totalPages - 1, page + 1); i++) {
          pageNumbers.push(i);
        }
        if (page < totalPages - 2) pageNumbers.push('...');
        pageNumbers.push(totalPages);
      }
      
      for (const num of pageNumbers) {
        if (num === '...') {
          html += '<span>...</span>';
        } else {
          const activeClass = num === page ? 'active' : '';
          html += `<button class="${activeClass}" onclick="goToPage(${num})">${num}</button>`;
        }
      }
      
      if (page < totalPages) {
        html += `<button onclick="goToPage(${page + 1})">Next →</button>`;
      }
      
      html += '</div>';
    }
    
    container.innerHTML = html;
    
    // Update stats
    document.getElementById('total-results').textContent = 
      `Showing ${start + 1}-${end} of ${totalResults} results`;
  }
  
  // Go to page (exposed globally)
  window.goToPage = function(page) {
    currentPage = page;
    displayResults(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };
  
  // Handle search
  let searchTimeout;
  async function handleSearch() {
    // Only search if on the search tab
    if (!document.getElementById('tab-search').checked) {
      return;
    }
    
    const query = document.getElementById('package-search').value;
    
    clearTimeout(searchTimeout);
    
    if (query.length < 2) {
      document.getElementById('results-container').innerHTML = `
        <div class="instructions">
          <h3>🔍 How to use</h3>
          <ul>
            <li><strong>Type to search:</strong> Enter a package name (partial matches work)</li>
            <li><strong>Filter results:</strong> Use checkboxes to filter by platform support</li>
            <li><strong>View details:</strong> Click on a package to see version and source info</li>
          </ul>
          <p class="tip">💡 <strong>Tip:</strong> Search is case-insensitive and searches across all 702,223 packages in real-time.</p>
        </div>
      `;
      document.getElementById('total-results').textContent = 'Ready to search 702,223 packages';
      document.getElementById('search-time').textContent = '';
      return;
    }
    
    document.getElementById('results-container').innerHTML = 
      '<div class="loading">🔍 Searching through packages...</div>';
    
    searchTimeout = setTimeout(async () => {
      currentResults = await searchPackages(query);
      currentPage = 1;
      displayResults(1);
    }, 300);
  }
  
  // Show error message
  function showError(message) {
    document.getElementById('results-container').innerHTML = 
      `<div class="no-results">❌ ${message}</div>`;
  }
  
  // Initialize
  async function init() {
    await loadIndex();
    
    // Set up event listeners
    document.getElementById('package-search').addEventListener('input', handleSearch);
    
    // Filter checkboxes
    ['filter-ios', 'filter-android', 'filter-pure', 'filter-binary'].forEach(id => {
      document.getElementById(id).addEventListener('change', handleSearch);
    });
    
    // Initialize requirements tab
    setupRequirementsTab();
    
    console.log('Package search initialized');
  }
  
  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  
  // === Requirements Analysis Functionality ===
  
  // Parse requirements.txt line
  function parseRequirement(line) {
    line = line.trim();
    if (!line || line.startsWith('#')) return null;
    
    // Match package name and version specifier
    const match = line.match(/^([a-zA-Z0-9_-]+)(.*?)$/);
    if (!match) return null;
    
    return {
      name: match[1].toLowerCase(),
      version: match[2].trim() || '',
      original: line
    };
  }
  
  // Analyze requirements
  async function analyzeRequirements(requirements) {
    const results = [];
    const startTime = performance.now();
    
    for (const req of requirements) {
      if (!req) continue;
      
      // Search for the package
      let found = null;
      for (const chunk of indexData.chunks) {
        const packages = await loadChunk(chunk.filename);
        const pkg = packages.find(p => p.name.toLowerCase() === req.name);
        
        if (pkg) {
          found = pkg;
          break;
        }
      }
      
      results.push({
        requirement: req,
        package: found
      });
    }
    
    const endTime = performance.now();
    const analysisTime = ((endTime - startTime) / 1000).toFixed(2);
    
    return { results, analysisTime };
  }
  
  // Display requirements results
  function displayRequirementsResults(analysis) {
    const { results, analysisTime } = analysis;
    const container = document.getElementById('requirements-results');
    const statsBar = document.getElementById('requirements-stats');
    
    // Calculate statistics
    let iosCount = 0, androidCount = 0, pureCount = 0, missingCount = 0;
    
    results.forEach(r => {
      if (!r.package) {
        missingCount++;
      } else {
        if (r.package.ios === 'supported') iosCount++;
        if (r.package.android === 'supported') androidCount++;
        if (r.package.ios === 'pure_python' || r.package.android === 'pure_python') pureCount++;
      }
    });
    
    // Update stats
    document.getElementById('req-total').textContent = `Total: ${results.length}`;
    document.getElementById('req-ios').textContent = `iOS: ${iosCount}`;
    document.getElementById('req-android').textContent = `Android: ${androidCount}`;
    document.getElementById('req-pure').textContent = `Pure Python: ${pureCount}`;
    document.getElementById('req-missing').textContent = `Not Found: ${missingCount}`;
    statsBar.style.display = 'flex';
    
    // Build results table
    let html = `
      <div style="margin-bottom: 10px; color: var(--md-default-fg-color--light);">
        Analysis completed in ${analysisTime}s
      </div>
      <table class="requirements-table">
        <thead>
          <tr>
            <th>Package</th>
            <th>iOS</th>
            <th>Android</th>
            <th>Category</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    for (const result of results) {
      const req = result.requirement;
      const pkg = result.package;
      
      if (!pkg) {
        html += `
          <tr>
            <td>
              <div class="package-name">${req.name}</div>
              <div class="version-spec">${req.version}</div>
            </td>
            <td colspan="3">
              <span class="status-badge status-not-available">❌ Package not found in database</span>
            </td>
          </tr>
        `;
      } else {
        html += `
          <tr>
            <td>
              <div class="package-name">${pkg.name}</div>
              <div class="version-spec">${req.version}</div>
              <div class="package-details">Source: ${pkg.source || 'Unknown'}</div>
            </td>
            <td>${formatStatus(pkg.ios, pkg.iosVersion)}</td>
            <td>${formatStatus(pkg.android, pkg.androidVersion)}</td>
            <td>${getCategoryName(pkg.category)}</td>
          </tr>
        `;
      }
    }
    
    html += '</tbody></table>';
    container.innerHTML = html;
  }
  
  // Handle file upload
  function setupRequirementsTab() {
    const fileInput = document.getElementById('file-input');
    const uploadArea = document.getElementById('upload-area');
    const requirementsText = document.getElementById('requirements-text');
    const analyzeBtn = document.getElementById('analyze-btn');
    
    // File input change
    fileInput.addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (file) {
        const text = await file.text();
        requirementsText.value = text;
      }
    });
    
    // Drag and drop
    uploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      uploadArea.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', () => {
      uploadArea.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', async (e) => {
      e.preventDefault();
      uploadArea.classList.remove('dragover');
      
      const file = e.dataTransfer.files[0];
      if (file && file.name.endsWith('.txt')) {
        const text = await file.text();
        requirementsText.value = text;
      }
    });
    
    // Analyze button
    analyzeBtn.addEventListener('click', async () => {
      const text = requirementsText.value.trim();
      if (!text) {
        alert('Please upload a file or paste requirements');
        return;
      }
      
      if (!indexData) {
        alert('Package database is still loading. Please wait...');
        return;
      }
      
      analyzeBtn.disabled = true;
      analyzeBtn.textContent = '🔄 Analyzing...';
      
      try {
        const lines = text.split('\n');
        const requirements = lines.map(parseRequirement).filter(r => r !== null);
        
        const analysis = await analyzeRequirements(requirements);
        displayRequirementsResults(analysis);
      } catch (error) {
        console.error('Analysis error:', error);
        alert('Error analyzing requirements. Check console for details.');
      } finally {
        analyzeBtn.disabled = false;
        analyzeBtn.textContent = '🔍 Analyze Requirements';
      }
    });
  }
  
  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  
})();
</script>
