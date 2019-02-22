import mnist

def train_images():
    train_images = mnist.train_images()
    train_labels = mnist.train_labels()

    train_features = train_images.reshape(
        (train_images.shape[0], train_images.shape[1] * train_images.shape[2]))

    return train_features, train_labels
    
def test_images():
    test_images = mnist.test_images()
    test_labels = mnist.test_labels()

    test_features = test_images.reshape(
        (test_images.shape[0], test_images.shape[1] * test_images.shape[2]))

    return test_features, test_labels

def iter_train():
    imgs, lbl = train_images()
    for img, lbl in zip(imgs, lbl):
        yield img.astype('float').flatten().tolist(), lbl.astype('str').tolist()
