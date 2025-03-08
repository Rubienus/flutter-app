<?php
$user_list = $users->list_users();
$role_list = $users->list_roles();
?>
<!-- Bootstrap Modal Form -->
<button type="button" class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#addUserModal">Add New User</button>

<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="addUserModalLabel">Add New User</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="addUserForm">
          <div class="mb-3">
            <label for="first_name" class="form-label">First Name</label>
            <input type="text" class="form-control" name="first_name" required>
          </div>
          <div class="mb-3">
            <label for="last_name" class="form-label">Last Name</label>
            <input type="text" class="form-control" name="last_name" required>
          </div>
          <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="email" class="form-control" name="email" required>
          </div>
          <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input type="password" class="form-control" name="password" required>
          </div>
          <div class="mb-3">
            <label for="role_id" class="form-label">Role ID</label>
            <select class="form-control" name="role_id" required>
            <?php foreach ($role_list as $role): ?>
              <option value="<?php echo $role['role_id'] ;?>"><?php echo $role['role_name'] ;?></option>
            <?php endforeach; ?>
            </select>
          </div>
          <div class="mb-3">
            <label for="status" class="form-label">Status</label>
            <select class="form-control" name="status" required>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="banned">Banned</option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary">Submit</button>
        </form>
        
      </div>
    </div>
  </div>
</div>
<div id="responseMessage" class="mt-3"></div>
    <table class="table table-striped">
        <thead>
            <tr>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Email</th>
                <th>Role ID</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($user_list as $user): ?>
                <tr>
                    <td><?php echo $user['user_first_name'] ;?></td>
                    <td><?php echo $user['user_last_name'] ;?></td>
                    <td><?php echo $user['user_email'] ;?></td>
                    <td><?php echo $user['role_id'] ;?></td>
                    <td><?php echo $user['user_status'] ;?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
<script>
  document.getElementById('addUserForm').onsubmit = async function(event) {
  event.preventDefault();

  let formData = new FormData(this);

  try {
    let response = await fetch('process.users.php', {
      method: 'POST',
      body: formData
    });

    let result = await response.json();

    let messageDiv = document.getElementById('responseMessage');
    if (result.status === 'success') {
      messageDiv.innerHTML = '<div class="alert alert-success">' + result.message + '</div>';

      // Close the modal
      let modal = bootstrap.Modal.getInstance(document.getElementById('addUserModal'));
      modal.hide();

      // Clear form inputs
      this.reset();

      // Optional: Reload the page to show updated data
      setTimeout(() => {
        location.reload();
      }, 1500);
    } else {
      messageDiv.innerHTML = '<div class="alert alert-danger">' + result.message + '</div>';
    }
  } catch (error) {
    console.error('Error:', error);
  }
};
</script>